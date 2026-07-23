using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Domain.Operations;
using ECommerce.Infrastructure.Persistence;
using ECommerce.Infrastructure.Security;
namespace ECommerce.Infrastructure.Outbox;
public sealed class OutboxWriter(AppDbContext db, AesGcmSecretProtector protector, IIdGenerator ids, IClock clock) : IOutboxWriter
{
    public void Add(string messageType, object payload) => db.OutboxMessages.Add(new OutboxMessage
    {
        Id = ids.NewId("out"), MessageType = messageType,
        EncryptedPayload = protector.Protect(JsonSerializer.Serialize(payload)), CreatedAtUtc = clock.UtcNow
    });
}
