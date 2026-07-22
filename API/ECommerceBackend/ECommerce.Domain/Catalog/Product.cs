using ECommerce.Domain.Common;
using ECommerce.Domain.Profiles;

namespace ECommerce.Domain.Catalog;

public sealed class Product : EntityBase
{
    public string SellerProfileId { get; set; } = string.Empty;
    public SellerProfile SellerProfile { get; set; } = null!;
    public string CategoryId { get; set; } = string.Empty;
    public Category Category { get; set; } = null!;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Stock { get; set; }
    public decimal RatingAverage { get; set; }
    public int ReviewCount { get; set; }
    public string FeaturesJson { get; set; } = "{}";
    public bool IsActive { get; set; } = true;
    public DateTime? DeactivatedAtUtc { get; set; }
    public ICollection<ProductPhoto> Photos { get; set; } = new List<ProductPhoto>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}
