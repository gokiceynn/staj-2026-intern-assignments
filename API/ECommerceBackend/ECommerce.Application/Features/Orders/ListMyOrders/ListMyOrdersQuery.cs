using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Orders.ListMyOrders;
public sealed record ListMyOrdersQuery(int Page = 1, int Size = 10, string? Status = null);
public sealed record ListMyOrdersResult(PagedResult<OrderListItemDto> Page);
