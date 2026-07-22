using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
namespace ECommerce.Application.Features.AdminUsers.ListAdminUsers;
public sealed class ListAdminUsersHandler(IAdminQueryService queries)
{ public Task<Result<PagedResult<AdminUserListItem>>> HandleAsync(ListAdminUsersQuery query, CancellationToken ct) => queries.ListUsersAsync(query.Page, query.Size, query.Q, query.Role, query.IsActive, ct); }
