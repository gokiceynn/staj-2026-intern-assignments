using ECommerce.Domain.Common;

namespace ECommerce.Domain.Identity;

public sealed class AccessTokenRecord : EntityBase
{
    public string Jti { get; set; } = string.Empty;
    public string AccountId { get; set; } = string.Empty;
    public Account Account { get; set; } = null!;
    public string RefreshSessionId { get; set; } = string.Empty;
    public RefreshSession RefreshSession { get; set; } = null!;
    public int AccountSecurityVersion { get; set; }
    public DateTime IssuedAtUtc { get; set; }
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime? RevokedAtUtc { get; set; }
    public string? RevocationReason { get; set; }
    public string IssuedByIp { get; set; } = string.Empty;
    public string UserAgentHash { get; set; } = string.Empty;
}
