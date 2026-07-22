using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Orders.GetMyOrder;
public sealed class GetMyOrderHandler(IOrderService orders, ICurrentUser currentUser)
{ public Task<Result<OrderDetailDto>> HandleAsync(GetMyOrderQuery query, CancellationToken ct) => orders.GetCustomerOrderAsync(currentUser.AccountId, query.Id, ct); }
