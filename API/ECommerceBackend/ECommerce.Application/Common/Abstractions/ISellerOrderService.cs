using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.SellerOrders;
namespace ECommerce.Application.Common.Abstractions;
public interface ISellerOrderService
{
    Task<Result<SellerPackagePage>> ListAsync(string accountId, int page, int size, string? status, DateTime? from, DateTime? to, CancellationToken ct);
    Task<Result<SellerPackageDetail>> GetAsync(string accountId, string packageId, CancellationToken ct);
    Task<Result<PackageTransitionResult>> PrepareAsync(string accountId, string packageId, CancellationToken ct);
    Task<Result<PackageTransitionResult>> ShipAsync(string accountId, string packageId, string carrierId, string trackingNumber, CancellationToken ct);
    Task<Result<PackageTransitionResult>> DeliverAsync(string accountId, string packageId, CancellationToken ct);
}
