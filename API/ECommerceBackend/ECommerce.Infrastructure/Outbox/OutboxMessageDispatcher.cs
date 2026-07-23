using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Redis;
using ECommerce.Domain.Operations;
using ECommerce.Infrastructure.Persistence;
using ECommerce.Infrastructure.Security;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Infrastructure.Outbox;
public sealed class OutboxMessageDispatcher(
    AesGcmSecretProtector protector, IEmailSender email, AppDbContext db,
    ISecurityRedisStore redis, IClock clock) : IOutboxMessageDispatcher
{
    public async Task DispatchAsync(OutboxMessage message, CancellationToken ct)
    {
        string json = protector.Unprotect(message.EncryptedPayload);
        using JsonDocument doc = JsonDocument.Parse(json);
        if (message.MessageType == "SendOtpEmail")
        {
            string to = doc.RootElement.GetProperty("to").GetString()!;
            string code = doc.RootElement.GetProperty("code").GetString()!;
            await email.SendAsync(to, "Doğrulama kodunuz", $"<p>Doğrulama kodunuz: <strong>{System.Net.WebUtility.HtmlEncode(code)}</strong></p>", ct);
            return;
        }
        if (message.MessageType is "SecurityTokensRevoked" or "AccountSecurityChanged")
        {
            string accountId = doc.RootElement.GetProperty("accountId").GetString()!;
            int version = await db.Accounts.AsNoTracking().Where(x => x.Id == accountId).Select(x => x.SecurityVersion).SingleAsync(ct);
            DateTime now = clock.UtcNow;
            var tokens = await db.AccessTokenRecords.AsNoTracking().Where(x => x.AccountId == accountId && x.RevokedAtUtc != null && x.ExpiresAtUtc > now)
                .Select(x => new BlacklistEntry(x.Jti, x.ExpiresAtUtc)).ToListAsync(ct);
            var sessions = await db.RefreshSessions.AsNoTracking().Where(x => x.AccountId == accountId && x.RevokedAtUtc != null && x.ExpiresAtUtc > now)
                .Select(x => new RevokedSessionEntry(x.Id, x.ExpiresAtUtc)).ToListAsync(ct);
            await redis.CompleteAccountRevocationAsync(accountId, version, tokens, sessions, ct);
        }
    }
}
