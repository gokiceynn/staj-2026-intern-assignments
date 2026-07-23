using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Common.Abstractions;
public interface IShippingCarrierAdminService
{
    Task<Result<AdminShippingCarrierDto>> CreateAsync(ShippingCarrierWriteModel model, string actorId, CancellationToken ct);
    Task<Result<AdminShippingCarrierDto>> UpdateAsync(string id, ShippingCarrierWriteModel model, string actorId, CancellationToken ct);
    Task<Result> DeleteAsync(string id, string actorId, CancellationToken ct);
}
public sealed record ShippingCarrierWriteModel(string Name, string Code, string? LogoId, decimal FlatFee,
    int EstimatedDeliveryDays, string TrackingUrlTemplate, bool IsActive);
