using ECommerce.Domain.Media;

namespace ECommerce.Domain.Catalog;

public sealed class ProductPhoto
{
    public string ProductId { get; set; } = string.Empty;
    public Product Product { get; set; } = null!;
    public string PhotoId { get; set; } = string.Empty;
    public Photo Photo { get; set; } = null!;
    public int DisplayOrder { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}
