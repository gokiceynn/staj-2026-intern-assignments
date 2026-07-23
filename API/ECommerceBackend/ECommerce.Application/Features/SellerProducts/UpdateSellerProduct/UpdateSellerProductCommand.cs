namespace ECommerce.Application.Features.SellerProducts.UpdateSellerProduct;
public sealed record UpdateSellerProductCommand(string Id, string Title, string Description, decimal Price, int Stock, string CategoryId,
    IReadOnlyList<string> PhotoIds, IReadOnlyDictionary<string, string> Features, bool IsActive);
