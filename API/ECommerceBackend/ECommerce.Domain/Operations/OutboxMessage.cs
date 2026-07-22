using ECommerce.Domain.Common;
using ECommerce.Domain.Common.Enums;

namespace ECommerce.Domain.Operations;

public sealed class OutboxMessage : EntityBase
{
    public string MessageType { get; set; } = string.Empty;
    public string EncryptedPayload { get; set; } = string.Empty;
    public OutboxStatus Status { get; set; } = OutboxStatus.Pending;
    public int AttemptCount { get; set; }
    public DateTime? NextAttemptAtUtc { get; set; }
    public string? LockId { get; set; }
    public DateTime? LockedUntilUtc { get; set; }
    public DateTime? ProcessedAtUtc { get; set; }
    public string? LastError { get; set; }
}
