using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminSellers.ListAdminSellers;
public sealed class ListAdminSellersHandler(IAdminQueryService queries)
{ public Task<Result<PagedResult<AdminSellerListItem>>> HandleAsync(ListAdminSellersQuery query, CancellationToken ct) => queries.ListSellersAsync(query.Page, query.Size, query.Q, query.IsActive, ct); }
