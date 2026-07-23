using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Catalog.ListProducts;
public sealed record ListProductsQuery(int Page = 1, int Size = 12, string? Q = null, string? CategoryId = null,
    string? SellerId = null, decimal? MinPrice = null, decimal? MaxPrice = null, bool? InStock = null, string SortBy = "newest");
public sealed record ListProductsResult(PagedResult<ProductCard> Page);
