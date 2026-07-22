using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.SellerProducts;
namespace ECommerce.Application.Common.Abstractions;
public interface ISellerProductService
{
    Task<Result<SellerProductPage>> ListAsync(string accountId, int page, int size, string? q, bool? isActive, CancellationToken ct);
    Task<Result<SellerProductDetail>> GetAsync(string accountId, string productId, CancellationToken ct);
    Task<Result<SellerProductDetail>> CreateAsync(string accountId, ProductWriteModel model, CancellationToken ct);
    Task<Result<SellerProductDetail>> UpdateAsync(string accountId, string productId, ProductWriteModel model, CancellationToken ct);
    Task<Result> DeleteAsync(string accountId, string productId, CancellationToken ct);
}
public sealed record ProductWriteModel(string Title, string Description, decimal Price, int Stock, string CategoryId,
    IReadOnlyList<string> PhotoIds, IReadOnlyDictionary<string, string> Features, bool IsActive);
