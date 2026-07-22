using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminShippingCarriers.List;
public sealed class ListAdminShippingCarriersHandler(IAdminQueryService queries)
{ public Task<Result<IReadOnlyList<AdminShippingCarrierDto>>> HandleAsync(ListAdminShippingCarriersQuery query, CancellationToken ct) => queries.ListCarriersAsync(ct); }
