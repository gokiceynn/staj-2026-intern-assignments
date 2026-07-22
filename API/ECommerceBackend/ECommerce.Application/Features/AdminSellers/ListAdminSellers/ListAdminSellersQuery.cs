namespace ECommerce.Application.Features.AdminSellers.ListAdminSellers;
public sealed record ListAdminSellersQuery(int Page = 1, int Size = 20, string? Q = null, bool? IsActive = null);
