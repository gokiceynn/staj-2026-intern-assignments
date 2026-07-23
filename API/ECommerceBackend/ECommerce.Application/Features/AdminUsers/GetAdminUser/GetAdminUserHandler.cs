using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminUsers.GetAdminUser;
public sealed class GetAdminUserHandler(IAdminQueryService queries)
{ public Task<Result<AdminUserDetail>> HandleAsync(GetAdminUserQuery query, CancellationToken ct) => queries.GetUserAsync(query.Id, ct); }
