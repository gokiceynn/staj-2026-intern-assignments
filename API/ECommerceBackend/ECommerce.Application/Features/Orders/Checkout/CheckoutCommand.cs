using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Orders.Checkout;
public sealed record CheckoutCommand(string AddressId, PaymentCardInput PaymentCard, string IdempotencyKey);
