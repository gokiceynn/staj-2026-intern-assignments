using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Catalog;
namespace ECommerce.Application.Features.SellerProducts;
public sealed record SellerProductCard(ProductCard Product, bool IsActive);
public sealed record SellerProductDetail(string Id, string Title, string Description, decimal Price, int Stock, string? PhotoId,
    IReadOnlyList<string> PhotoIds, decimal Rating, IReadOnlyDictionary<string, string> Features,
    string CategoryId, CategorySummary Category, bool IsActive, DateTime CreatedAtUtc, DateTime? UpdatedAtUtc);
public sealed record SellerProductPage(PagedResult<SellerProductCard> Page);
