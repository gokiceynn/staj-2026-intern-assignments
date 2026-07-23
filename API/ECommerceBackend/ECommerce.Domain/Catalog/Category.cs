using ECommerce.Domain.Common;
using ECommerce.Domain.Media;

namespace ECommerce.Domain.Catalog;

public sealed class Category : EntityBase
{
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? ParentCategoryId { get; set; }
    public Category? ParentCategory { get; set; }
    public string? IconPhotoId { get; set; }
    public Photo? IconPhoto { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public ICollection<Category> Children { get; set; } = new List<Category>();
    public ICollection<Product> Products { get; set; } = new List<Product>();
}
