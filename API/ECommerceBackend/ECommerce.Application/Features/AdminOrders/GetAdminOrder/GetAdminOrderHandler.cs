using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminOrders.GetAdminOrder;
public sealed class GetAdminOrderHandler(IAdminQueryService queries)
{ public Task<Result<AdminOrderDetail>> HandleAsync(GetAdminOrderQuery query, CancellationToken ct) => queries.GetOrderAsync(query.Id, ct); }
