using ECommerce.Domain.Common;

namespace ECommerce.Domain.Identity;

public sealed class Role : EntityBase
{
    public string Code { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public bool IsSystemRole { get; set; } = true;
    public ICollection<Account> Accounts { get; set; } = new List<Account>();
}
