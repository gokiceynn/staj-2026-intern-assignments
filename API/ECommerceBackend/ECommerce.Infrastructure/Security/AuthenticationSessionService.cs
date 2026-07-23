using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Security;
using ECommerce.Domain.Identity;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace ECommerce.Infrastructure.Security;

public sealed class AuthenticationSessionService(
    AppDbContext db, ITransactionRunner transactions, IJwtTokenService jwt, IRefreshTokenService refreshTokens,
    JwtKeyProvider keys, IOptions<JwtOptions> options, IIdGenerator ids, IClock clock,
    ISecurityRedisStore redis, TokenRevocationCoordinator revocations) : IAuthenticationSessionService
{
    private readonly JwtOptions _options = options.Value;

    public Task<AuthenticatedAccount> CreateAsync(Account account, string ipAddress, string userAgent, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            string plainRefresh = refreshTokens.GeneratePlainToken();
            string sessionId = ids.NewId("ses");
            DateTime now = clock.UtcNow;
            IssuedAccessToken access = jwt.CreateAccessToken(account.Id, account.Role.Code, sessionId, account.SecurityVersion, now);
            DateTime refreshExpiry = now.AddDays(_options.RefreshTokenDays);
            RefreshSession session = new()
            {
                Id = sessionId, AccountId = account.Id, TokenHash = refreshTokens.HashToken(plainRefresh),
                TokenFamilyId = ids.NewId("fam"), AccountSecurityVersion = account.SecurityVersion,
                ExpiresAtUtc = refreshExpiry, CreatedByIp = ipAddress, UserAgentHash = HashUserAgent(userAgent), CreatedAtUtc = now
            };
            db.RefreshSessions.Add(session);
            db.AccessTokenRecords.Add(ToRecord(account.Id, session.Id, account.SecurityVersion, access, ipAddress, userAgent));
            await db.SaveChangesAsync(token);
            return new AuthenticatedAccount(
                new TokenPair(access.Token, access.ExpiresAtUtc, plainRefresh, refreshExpiry),
                new AccountSummary(account.Id, account.Email, account.FirstName, account.LastName, account.PhoneNumber, account.Role.Code, account.CreatedAtUtc));
        }, System.Data.IsolationLevel.ReadCommitted, ct);

    public async Task<Result<TokenPair>> RotateAsync(string refreshToken, string expiredAccessToken, string ipAddress, string userAgent, CancellationToken ct)
    {
        ClaimsPrincipal principal;
        try { principal = ValidateExpiredAccessToken(expiredAccessToken); }
        catch (SecurityTokenException) { return Result<TokenPair>.Failure(AuthErrors.InvalidRefreshToken); }

        string accountId = principal.FindFirst(ClaimNames.Subject)?.Value ?? string.Empty;
        string oldSessionId = principal.FindFirst(ClaimNames.SessionId)?.Value ?? string.Empty;
        string oldJti = principal.FindFirst(ClaimNames.JwtId)?.Value ?? string.Empty;
        string hash = refreshTokens.HashToken(refreshToken);
        RotationOutcome outcome = await transactions.ExecuteAsync(async token =>
        {
            RefreshSession? old = await db.RefreshSessions
                .FromSqlInterpolated($"SELECT * FROM refresh_sessions WHERE token_hash = {hash} FOR UPDATE")
                .SingleOrDefaultAsync(token);
            if (old is null || old.AccountId != accountId || old.Id != oldSessionId)
                return RotationOutcome.Invalid;

            DateTime now = clock.UtcNow;
            if (old.RevokedAtUtc is not null || old.ReplacedBySessionId is not null)
            {
                old.ReuseDetectedAtUtc = now;
                await db.SaveChangesAsync(token);
                await redis.BeginAccountRevocationAsync(old.AccountId, TimeSpan.FromMinutes(5), token);
                return RotationOutcome.Reuse(old.AccountId, old.Id);
            }
            if (old.ExpiresAtUtc <= now || old.AccountSecurityVersion != principal.GetIntClaim(ClaimNames.SecurityVersion))
                return RotationOutcome.Invalid;

            AccessTokenRecord? oldAccess = await db.AccessTokenRecords.SingleOrDefaultAsync(x => x.Jti == oldJti && x.RefreshSessionId == old.Id, token);
            if (oldAccess is null || oldAccess.RevokedAtUtc is not null) return RotationOutcome.Invalid;
            Account account = await db.Accounts.Include(x => x.Role).SingleAsync(x => x.Id == old.AccountId && x.IsActive, token);

            string nextPlain = refreshTokens.GeneratePlainToken();
            string nextSessionId = ids.NewId("ses");
            DateTime nextExpiry = now.AddDays(_options.RefreshTokenDays);
            IssuedAccessToken nextAccess = jwt.CreateAccessToken(account.Id, account.Role.Code, nextSessionId, account.SecurityVersion, now);
            RefreshSession next = new()
            {
                Id = nextSessionId, AccountId = account.Id, TokenHash = refreshTokens.HashToken(nextPlain), TokenFamilyId = old.TokenFamilyId,
                ParentSessionId = old.Id, AccountSecurityVersion = account.SecurityVersion, ExpiresAtUtc = nextExpiry,
                CreatedByIp = ipAddress, UserAgentHash = HashUserAgent(userAgent), CreatedAtUtc = now
            };
            old.RevokedAtUtc = now; old.LastUsedAtUtc = now; old.ReplacedBySessionId = next.Id; old.RevocationReason = "rotated"; old.RevokedByIp = ipAddress;
            oldAccess.RevokedAtUtc = now; oldAccess.RevocationReason = "refresh-rotated";
            db.RefreshSessions.Add(next);
            db.AccessTokenRecords.Add(ToRecord(account.Id, next.Id, account.SecurityVersion, nextAccess, ipAddress, userAgent));
            await db.SaveChangesAsync(token);
            return RotationOutcome.Success(new TokenPair(nextAccess.Token, nextAccess.ExpiresAtUtc, nextPlain, nextExpiry), oldAccess.Jti, oldAccess.ExpiresAtUtc, old.Id, old.ExpiresAtUtc);
        }, System.Data.IsolationLevel.Serializable, ct);

        if (outcome.ReuseDetected)
        {
            await revocations.RevokeAllAsync(outcome.AccountId!, "refresh-token-reuse", ipAddress, ct);
            return Result<TokenPair>.Failure(AuthErrors.RefreshTokenReuse);
        }
        if (outcome.Tokens is null) return Result<TokenPair>.Failure(AuthErrors.InvalidRefreshToken);
        await redis.BlacklistJtiAsync(outcome.OldJti!, outcome.OldAccessExpiry - clock.UtcNow, ct);
        await redis.RevokeSessionAsync(outcome.OldSessionId!, outcome.OldSessionExpiry - clock.UtcNow, ct);
        return Result<TokenPair>.Success(outcome.Tokens);
    }

    public async Task LogoutAsync(string accountId, string sessionId, string jti, string ipAddress, CancellationToken ct)
    {
        var expiry = await transactions.ExecuteAsync(async token =>
        {
            RefreshSession? session = await db.RefreshSessions.SingleOrDefaultAsync(x => x.Id == sessionId && x.AccountId == accountId, token);
            AccessTokenRecord? access = await db.AccessTokenRecords.SingleOrDefaultAsync(x => x.Jti == jti && x.AccountId == accountId, token);
            DateTime now = clock.UtcNow;
            if (session is not null && session.RevokedAtUtc is null) { session.RevokedAtUtc = now; session.RevocationReason = "logout"; session.RevokedByIp = ipAddress; }
            if (access is not null && access.RevokedAtUtc is null) { access.RevokedAtUtc = now; access.RevocationReason = "logout"; }
            await db.SaveChangesAsync(token);
            return (Access: access?.ExpiresAtUtc ?? now, Session: session?.ExpiresAtUtc ?? now);
        }, System.Data.IsolationLevel.ReadCommitted, ct);
        await redis.BlacklistJtiAsync(jti, expiry.Access - clock.UtcNow, ct);
        await redis.RevokeSessionAsync(sessionId, expiry.Session - clock.UtcNow, ct);
    }

    private ClaimsPrincipal ValidateExpiredAccessToken(string token)
    {
        TokenValidationParameters p = new()
        {
            ValidateIssuerSigningKey = true, IssuerSigningKeys = keys.ValidationKeys, ValidateIssuer = true, ValidIssuer = _options.Issuer,
            ValidateAudience = true, ValidAudience = _options.Audience, ValidateLifetime = false, RequireExpirationTime = true,
            RequireSignedTokens = true, ValidAlgorithms = [SecurityAlgorithms.RsaSha256], ClockSkew = TimeSpan.Zero
        };
        ClaimsPrincipal principal = new JwtSecurityTokenHandler().ValidateToken(token, p, out SecurityToken validated);
        if (validated is not JwtSecurityToken jwtToken || jwtToken.ValidTo > clock.UtcNow.AddMinutes(5)) throw new SecurityTokenException();
        return principal;
    }

    private AccessTokenRecord ToRecord(string accountId, string sessionId, int securityVersion, IssuedAccessToken token, string ip, string ua) =>
        new() { Id = ids.NewId("atk"), Jti = token.Jti, AccountId = accountId, RefreshSessionId = sessionId,
            AccountSecurityVersion = securityVersion, IssuedAtUtc = token.IssuedAtUtc, ExpiresAtUtc = token.ExpiresAtUtc,
            IssuedByIp = ip, UserAgentHash = HashUserAgent(ua), CreatedAtUtc = token.IssuedAtUtc };

    private static string HashUserAgent(string value) => Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(value))).ToLowerInvariant();

    private sealed record RotationOutcome(TokenPair? Tokens, bool ReuseDetected, string? AccountId, string? OldJti,
        DateTime OldAccessExpiry, string? OldSessionId, DateTime OldSessionExpiry)
    {
        public static readonly RotationOutcome Invalid = new(null, false, null, null, default, null, default);
        public static RotationOutcome Reuse(string accountId, string sessionId) => new(null, true, accountId, null, default, sessionId, default);
        public static RotationOutcome Success(TokenPair pair, string jti, DateTime accessExpiry, string sid, DateTime sessionExpiry) =>
            new(pair, false, null, jti, accessExpiry, sid, sessionExpiry);
    }
}

internal static class ClaimsPrincipalExtensions
{
    public static int GetIntClaim(this ClaimsPrincipal principal, string name) =>
        int.TryParse(principal.FindFirst(name)?.Value, out int value) ? value : -1;
}
