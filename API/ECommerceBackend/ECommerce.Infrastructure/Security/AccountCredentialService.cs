using System.Security.Cryptography;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Domain.Identity;
using ECommerce.Domain.Operations;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Infrastructure.Security;

public sealed class AccountCredentialService(
    AppDbContext db, ITransactionRunner transactions, IPasswordHasher passwords, ISecurityRedisStore redis,
    IOutboxWriter outbox, IIdGenerator ids, IClock clock) : IAccountCredentialService
{
    public Task<Result> ChangePasswordAsync(string accountId, string currentPassword, string newPassword, string ipAddress, CancellationToken ct) =>
        MutateAndRevokeAsync(accountId, "password-change", ipAddress, account =>
        {
            if (!passwords.Verify(currentPassword, account.PasswordHash)) return AuthErrors.InvalidCredentials;
            account.PasswordHash = passwords.Hash(newPassword); account.PasswordHashVersion++;
            return null;
        }, ct);

    public Task<Result> ResetPasswordAsync(string accountId, string newPassword, string ipAddress, CancellationToken ct) =>
        MutateAndRevokeAsync(accountId, "password-reset", ipAddress, account =>
        { account.PasswordHash = passwords.Hash(newPassword); account.PasswordHashVersion++; return null; }, ct);

    public async Task<Result> ChangeEmailAsync(string accountId, string newEmail, string ipAddress, CancellationToken ct)
    {
        string normalized = newEmail.Trim().ToUpperInvariant();
        if (await db.Accounts.AnyAsync(x => x.NormalizedEmail == normalized && x.Id != accountId, ct)) return Result.Failure(AuthErrors.EmailAlreadyExists);
        return await MutateAndRevokeAsync(accountId, "email-change", ipAddress, account =>
        { account.Email = newEmail.Trim(); account.NormalizedEmail = normalized; account.IsEmailVerified = true; return null; }, ct);
    }

    public Task<Result> DeleteCustomerAsync(string accountId, string password, string ipAddress, CancellationToken ct) =>
        MutateAndRevokeAsync(accountId, "customer-delete", ipAddress, account =>
        {
            if (!passwords.Verify(password, account.PasswordHash)) return AuthErrors.InvalidCredentials;
            string anonymous = $"deleted-{account.Id}@invalid.local";
            account.Email = anonymous; account.NormalizedEmail = anonymous.ToUpperInvariant();
            account.FirstName = "Deleted"; account.LastName = "User"; account.PhoneNumber = string.Empty;
            account.PasswordHash = Convert.ToHexString(RandomNumberGenerator.GetBytes(64));
            account.IsActive = false; account.DeletedAtUtc = clock.UtcNow;
            foreach (var address in db.Addresses.Where(x => x.AccountId == accountId && x.IsActive))
            { address.IsActive = false; address.DeletedAtUtc = clock.UtcNow; }
            return null;
        }, ct);

    private async Task<Result> MutateAndRevokeAsync(
        string accountId, string reason, string ipAddress, Func<Account, Error?> mutate, CancellationToken ct)
    {
        await redis.BeginAccountRevocationAsync(accountId, TimeSpan.FromHours(1), ct);
        Commit? commit = await transactions.ExecuteAsync(async token =>
        {
            Account? account = await db.Accounts.FromSqlInterpolated($"SELECT * FROM accounts WHERE id = {accountId} FOR UPDATE")
                .SingleOrDefaultAsync(token);
            if (account is null) return null;
            Error? error = mutate(account);
            if (error is not null) return new Commit(error, 0, [], []);
            DateTime now = clock.UtcNow;
            List<RefreshSession> sessions = await db.RefreshSessions.Where(x => x.AccountId == accountId && x.RevokedAtUtc == null && x.ExpiresAtUtc > now).ToListAsync(token);
            List<AccessTokenRecord> tokens = await db.AccessTokenRecords.Where(x => x.AccountId == accountId && x.RevokedAtUtc == null && x.ExpiresAtUtc > now).ToListAsync(token);
            account.SecurityVersion++; account.UpdatedAtUtc = now;
            foreach (var session in sessions) { session.RevokedAtUtc = now; session.RevocationReason = reason; session.RevokedByIp = ipAddress; }
            foreach (var access in tokens) { access.RevokedAtUtc = now; access.RevocationReason = reason; }
            db.AuditLogs.Add(new AuditLog { Id = ids.NewId("aud"), ActorAccountId = accountId, Action = reason,
                EntityType = "Account", EntityId = accountId, CorrelationId = ids.NewId("cor"), IpAddress = ipAddress,
                UserAgentHash = string.Empty, MetadataJson = "{}", CreatedAtUtc = now });
            outbox.Add("AccountSecurityChanged", new { accountId, reason });
            await db.SaveChangesAsync(token);
            return new Commit(null, account.SecurityVersion,
                tokens.Select(x => new BlacklistEntry(x.Jti, x.ExpiresAtUtc)).ToList(),
                sessions.Select(x => new RevokedSessionEntry(x.Id, x.ExpiresAtUtc)).ToList());
        }, System.Data.IsolationLevel.Serializable, ct);

        if (commit is null) return Result.Failure(CommonErrors.NotFound);
        if (commit.Error is not null)
        {
            // Mutation olmadı; gereksiz block'u mevcut version ile güvenli şekilde kaldır.
            int version = await db.Accounts.Where(x => x.Id == accountId).Select(x => x.SecurityVersion).SingleAsync(ct);
            await redis.CompleteAccountRevocationAsync(accountId, version, [], [], ct);
            return Result.Failure(commit.Error);
        }
        await redis.CompleteAccountRevocationAsync(accountId, commit.SecurityVersion, commit.Tokens, commit.Sessions, ct);
        return Result.Success();
    }

    private sealed record Commit(Error? Error, int SecurityVersion, IReadOnlyCollection<BlacklistEntry> Tokens, IReadOnlyCollection<RevokedSessionEntry> Sessions);
}
