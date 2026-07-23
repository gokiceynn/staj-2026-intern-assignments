namespace ECommerce.Application.Features.SellerProducts.CreateSellerProduct;
public sealed record CreateSellerProductCommand(string Title, string Description, decimal Price, int Stock, string CategoryId,
    IReadOnlyList<string> PhotoIds, IReadOnlyDictionary<string, string> Features, bool IsActive);
