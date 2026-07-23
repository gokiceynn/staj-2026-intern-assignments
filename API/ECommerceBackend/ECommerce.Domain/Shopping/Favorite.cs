using ECommerce.Domain.Catalog;
using ECommerce.Domain.Identity;

namespace ECommerce.Domain.Shopping;

public sealed class Favorite
{
    public string CustomerAccountId { get; set; } = string.Empty;
    public Account CustomerAccount { get; set; } = null!;
    public string ProductId { get; set; } = string.Empty;
    public Product Product { get; set; } = null!;
    public DateTime AddedAtUtc { get; set; }
}
