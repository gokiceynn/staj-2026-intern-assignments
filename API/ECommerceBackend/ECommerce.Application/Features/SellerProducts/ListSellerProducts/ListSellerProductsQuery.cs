namespace ECommerce.Application.Features.SellerProducts.ListSellerProducts;
public sealed record ListSellerProductsQuery(int Page = 1, int Size = 10, string? Q = null, bool? IsActive = null);
