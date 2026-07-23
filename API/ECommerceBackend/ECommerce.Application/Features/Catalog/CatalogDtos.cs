namespace ECommerce.Application.Features.Catalog;

public sealed record CategorySummary(string Id, string Name, string? IconId, string? ParentCategoryId);
public sealed record SellerSummary(string Id, string StoreName, string? LogoId, decimal Rating);
public sealed record CategoryNode(string Id, string Name, string Slug, string? IconId, string? ParentCategoryId, int ProductCount, IReadOnlyList<CategoryNode> Children);
public sealed record ProductCard(string Id, string Title, string Description, decimal Price, int Stock, string? PhotoId, decimal Rating, CategorySummary Category, SellerSummary Seller);
public sealed record ProductDetail(string Id, string Title, string Description, decimal Price, int Stock, string? PhotoId,
    IReadOnlyList<string> PhotoIds, decimal Rating, int ReviewCount, IReadOnlyDictionary<string, string> Features,
    string CategoryId, CategorySummary Category, SellerSummary Seller, bool IsActive, DateTime CreatedAtUtc, DateTime? UpdatedAtUtc);
