using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Redis;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;

namespace ECommerce.Infrastructure.Security;

public sealed class TokenRevocationChecker(
    ISecurityRedisStore redis, AppDbContext db, IClock clock, ILogger<TokenRevocationChecker> logger) : ITokenRevocationChecker
{
    public async Task<bool> IsTokenValidAsync(string accountId, string jti, string sessionId, int securityVersion, CancellationToken ct)
    {
        try
        {
            TokenStateResult state = await redis.ValidateTokenStateAsync(accountId, jti, sessionId, securityVersion, ct);
            if (state.RejectionCode != "CACHE_MISS") return state.IsValid;
        }
        catch (RedisException ex)
        {
            logger.LogWarning(ex, "Redis token-state validation failed; using MySQL fallback.");
        }

        DateTime now = clock.UtcNow;
        var stateFromDb = await db.AccessTokenRecords.AsNoTracking()
            .Where(x => x.AccountId == accountId && x.Jti == jti && x.RefreshSessionId == sessionId)
            .Select(x => new
            {
                AccountActive = x.Account.IsActive,
                CurrentSecurityVersion = x.Account.SecurityVersion,
                AccessVersion = x.AccountSecurityVersion,
                AccessRevoked = x.RevokedAtUtc != null,
                x.ExpiresAtUtc,
                SessionRevoked = x.RefreshSession.RevokedAtUtc != null,
                SessionExpires = x.RefreshSession.ExpiresAtUtc
            }).SingleOrDefaultAsync(ct);
        bool valid = stateFromDb is not null && stateFromDb.AccountActive &&
            stateFromDb.CurrentSecurityVersion == securityVersion && stateFromDb.AccessVersion == securityVersion &&
            !stateFromDb.AccessRevoked && stateFromDb.ExpiresAtUtc > now && !stateFromDb.SessionRevoked && stateFromDb.SessionExpires > now;
        if (valid) await redis.SetSecurityVersionAsync(accountId, securityVersion, TimeSpan.FromDays(15), ct);
        return valid;
    }
}
