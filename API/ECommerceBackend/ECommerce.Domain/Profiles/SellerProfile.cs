using ECommerce.Domain.Catalog;
using ECommerce.Domain.Common;
using ECommerce.Domain.Identity;
using ECommerce.Domain.Media;

namespace ECommerce.Domain.Profiles;

public sealed class SellerProfile : EntityBase
{
    public string AccountId { get; set; } = string.Empty;
    public Account Account { get; set; } = null!;
    public string StoreName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string TaxNumber { get; set; } = string.Empty;
    public string TaxOffice { get; set; } = string.Empty;
    public string? LogoPhotoId { get; set; }
    public Photo? LogoPhoto { get; set; }
    public decimal RatingAverage { get; set; }
    public int RatingCount { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime? DeactivatedAtUtc { get; set; }
    public ICollection<Product> Products { get; set; } = new List<Product>();
}
