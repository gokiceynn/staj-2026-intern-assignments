using ECommerce.Domain.Catalog;

namespace ECommerce.Domain.Shopping;

public sealed class CartItem
{
    public string CartId { get; set; } = string.Empty;
    public Cart Cart { get; set; } = null!;
    public string ProductId { get; set; } = string.Empty;
    public Product Product { get; set; } = null!;
    public int Quantity { get; set; }
    public DateTime AddedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
    public long Version { get; set; }
}
