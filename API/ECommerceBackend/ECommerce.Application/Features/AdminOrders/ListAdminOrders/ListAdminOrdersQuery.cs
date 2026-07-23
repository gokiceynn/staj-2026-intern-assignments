namespace ECommerce.Application.Features.AdminOrders.ListAdminOrders;
public sealed record ListAdminOrdersQuery(int Page = 1, int Size = 20, string? Status = null, DateTime? From = null, DateTime? To = null);
