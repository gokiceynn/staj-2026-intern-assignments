using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Redis;
using ECommerce.Domain.Identity;
using ECommerce.Domain.Operations;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Infrastructure.Security;

public sealed class TokenRevocationCoordinator(
    AppDbContext db, ITransactionRunner transactions, ISecurityRedisStore redis,
    IOutboxWriter outbox, IIdGenerator ids, IClock clock)
{
    public async Task RevokeAllAsync(string accountId, string reason, string ipAddress, CancellationToken ct)
    {
        await redis.BeginAccountRevocationAsync(accountId, TimeSpan.FromHours(1), ct);
        RevocationCommit commit = await transactions.ExecuteAsync(async token =>
        {
            Account account = await db.Accounts
                .FromSqlInterpolated($"SELECT * FROM accounts WHERE id = {accountId} FOR UPDATE")
                .SingleAsync(token);
            DateTime now = clock.UtcNow;
            List<RefreshSession> sessions = await db.RefreshSessions
                .Where(x => x.AccountId == accountId && x.RevokedAtUtc == null && x.ExpiresAtUtc > now).ToListAsync(token);
            List<AccessTokenRecord> accessTokens = await db.AccessTokenRecords
                .Where(x => x.AccountId == accountId && x.RevokedAtUtc == null && x.ExpiresAtUtc > now).ToListAsync(token);

            account.SecurityVersion++;
            account.UpdatedAtUtc = now;
            foreach (RefreshSession item in sessions)
            { item.RevokedAtUtc = now; item.RevocationReason = reason; item.RevokedByIp = ipAddress; }
            foreach (AccessTokenRecord item in accessTokens)
            { item.RevokedAtUtc = now; item.RevocationReason = reason; }

            db.AuditLogs.Add(new AuditLog
            {
                Id = ids.NewId("aud"), ActorAccountId = accountId, Action = "security.revoke-all",
                EntityType = "Account", EntityId = accountId, CorrelationId = ids.NewId("cor"),
                IpAddress = ipAddress, UserAgentHash = string.Empty,
                MetadataJson = JsonSerializer.Serialize(new { reason, accessTokenCount = accessTokens.Count, sessionCount = sessions.Count }),
                CreatedAtUtc = now
            });
            outbox.Add("SecurityTokensRevoked", new { accountId, reason, securityVersion = account.SecurityVersion });
            await db.SaveChangesAsync(token);
            return new RevocationCommit(account.SecurityVersion,
                accessTokens.Select(x => new BlacklistEntry(x.Jti, x.ExpiresAtUtc)).ToList(),
                sessions.Select(x => new RevokedSessionEntry(x.Id, x.ExpiresAtUtc)).ToList());
        }, System.Data.IsolationLevel.Serializable, ct);

        try
        {
            await redis.CompleteAccountRevocationAsync(accountId, commit.SecurityVersion, commit.Tokens, commit.Sessions, ct);
        }
        catch
        {
            // Block anahtarı TTL sonuna kadar fail-closed kalır; outbox worker aynı commit verisinden Redis sync'i tekrarlar.
            throw;
        }
    }

    private sealed record RevocationCommit(int SecurityVersion, IReadOnlyCollection<BlacklistEntry> Tokens, IReadOnlyCollection<RevokedSessionEntry> Sessions);
}
