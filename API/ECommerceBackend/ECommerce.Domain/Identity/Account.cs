using ECommerce.Domain.Common;
using ECommerce.Domain.Profiles;

namespace ECommerce.Domain.Identity;

public sealed class Account : EntityBase
{
    public string Email { get; set; } = string.Empty;
    public string NormalizedEmail { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public int PasswordHashVersion { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string RoleId { get; set; } = string.Empty;
    public Role Role { get; set; } = null!;
    public bool IsEmailVerified { get; set; }
    public bool IsActive { get; set; } = true;
    public int AccessFailedCount { get; set; }
    public DateTime? LockoutEndUtc { get; set; }
    public int SecurityVersion { get; set; } = 1;
    public DateTime? LastLoginAtUtc { get; set; }
    public DateTime? DeletedAtUtc { get; set; }
    public SellerProfile? SellerProfile { get; set; }
    public ICollection<Address> Addresses { get; set; } = new List<Address>();
    public ICollection<RefreshSession> RefreshSessions { get; set; } = new List<RefreshSession>();
    public ICollection<AccessTokenRecord> AccessTokens { get; set; } = new List<AccessTokenRecord>();
}
