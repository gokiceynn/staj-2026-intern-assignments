using ECommerce.Domain.Common;

namespace ECommerce.Domain.Identity;

public sealed class RefreshSession : EntityBase
{
    public string AccountId { get; set; } = string.Empty;
    public Account Account { get; set; } = null!;
    public string TokenHash { get; set; } = string.Empty;
    public string TokenFamilyId { get; set; } = string.Empty;
    public string? ParentSessionId { get; set; }
    public string? ReplacedBySessionId { get; set; }
    public int AccountSecurityVersion { get; set; }
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime? LastUsedAtUtc { get; set; }
    public DateTime? RevokedAtUtc { get; set; }
    public DateTime? ReuseDetectedAtUtc { get; set; }
    public string? RevocationReason { get; set; }
    public string CreatedByIp { get; set; } = string.Empty;
    public string? RevokedByIp { get; set; }
    public string UserAgentHash { get; set; } = string.Empty;
    public ICollection<AccessTokenRecord> AccessTokens { get; set; } = new List<AccessTokenRecord>();
}
