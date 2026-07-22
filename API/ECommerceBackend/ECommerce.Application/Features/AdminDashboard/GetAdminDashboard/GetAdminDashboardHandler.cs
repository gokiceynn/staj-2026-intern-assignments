using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminDashboard.GetAdminDashboard;
public sealed class GetAdminDashboardHandler(IAdminQueryService queries)
{ public Task<Result<AdminDashboardDto>> HandleAsync(GetAdminDashboardQuery query, CancellationToken ct) => queries.GetDashboardAsync(query.From, query.To, ct); }
