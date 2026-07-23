using ECommerce.Domain.Common;
using ECommerce.Domain.Identity;

namespace ECommerce.Domain.Shopping;

public sealed class Cart : EntityBase
{
    public string CustomerAccountId { get; set; } = string.Empty;
    public Account CustomerAccount { get; set; } = null!;
    public bool IsActive { get; set; } = true;
    public ICollection<CartItem> Items { get; set; } = new List<CartItem>();
}
