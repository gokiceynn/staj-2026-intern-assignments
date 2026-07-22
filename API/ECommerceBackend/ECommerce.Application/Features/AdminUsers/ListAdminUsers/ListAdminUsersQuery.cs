namespace ECommerce.Application.Features.AdminUsers.ListAdminUsers;
public sealed record ListAdminUsersQuery(int Page = 1, int Size = 20, string? Q = null, string? Role = null, bool? IsActive = null);
