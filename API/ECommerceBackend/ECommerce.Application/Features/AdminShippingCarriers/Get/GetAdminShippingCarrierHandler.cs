using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminShippingCarriers.Get;
public sealed class GetAdminShippingCarrierHandler(IAdminQueryService queries)
{ public Task<Result<AdminShippingCarrierDto>> HandleAsync(GetAdminShippingCarrierQuery query, CancellationToken ct) => queries.GetCarrierAsync(query.Id, ct); }
