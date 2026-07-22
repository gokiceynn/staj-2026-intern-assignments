using ECommerce.Domain.Common;

namespace ECommerce.Domain.Operations;

public sealed class AuditLog : EntityBase
{
    public string? ActorAccountId { get; set; }
    public string Action { get; set; } = string.Empty;
    public string EntityType { get; set; } = string.Empty;
    public string? EntityId { get; set; }
    public string CorrelationId { get; set; } = string.Empty;
    public string IpAddress { get; set; } = string.Empty;
    public string UserAgentHash { get; set; } = string.Empty;
    public string MetadataJson { get; set; } = "{}";
}
