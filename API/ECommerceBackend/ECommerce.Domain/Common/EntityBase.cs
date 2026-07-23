namespace ECommerce.Domain.Common;

public abstract class EntityBase
{
    public string Id { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
    public long Version { get; set; }
}
