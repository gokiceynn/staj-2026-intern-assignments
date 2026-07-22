namespace ECommerce.Application.Features.SellerOrders.ListSellerOrders;
public sealed record ListSellerOrdersQuery(int Page = 1, int Size = 10, string? Status = null, DateTime? From = null, DateTime? To = null);
