using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminSellers.GetAdminSeller;
public sealed class GetAdminSellerHandler(IAdminQueryService queries)
{ public Task<Result<AdminSellerDetail>> HandleAsync(GetAdminSellerQuery query, CancellationToken ct) => queries.GetSellerAsync(query.Id, ct); }
