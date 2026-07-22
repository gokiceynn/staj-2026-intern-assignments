using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminOrders.ListAdminOrders;
public sealed class ListAdminOrdersHandler(IAdminQueryService queries)
{ public Task<Result<PagedResult<AdminOrderListItem>>> HandleAsync(ListAdminOrdersQuery query, CancellationToken ct) => queries.ListOrdersAsync(query.Page, query.Size, query.Status, query.From, query.To, ct); }
