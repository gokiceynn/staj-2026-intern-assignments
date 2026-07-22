using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Orders;

namespace ECommerce.Application.Common.Abstractions;

public interface IOrderService
{
    Task<Result<OrderDetailDto>> CheckoutAsync(string accountId, string addressId, PaymentCardInput card, string idempotencyKey, CancellationToken ct);
    Task<Result<OrderDetailDto>> GetCustomerOrderAsync(string accountId, string orderId, CancellationToken ct);
    Task<Result<CancelOrderResult>> CancelAsync(string accountId, string orderId, string reason, CancellationToken ct);
}
