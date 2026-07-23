using ECommerce.Domain.Media;

namespace ECommerce.Domain.Catalog;

public sealed class ReviewPhoto
{
    public string ReviewId { get; set; } = string.Empty;
    public Review Review { get; set; } = null!;
    public string PhotoId { get; set; } = string.Empty;
    public Photo Photo { get; set; } = null!;
    public int DisplayOrder { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}
