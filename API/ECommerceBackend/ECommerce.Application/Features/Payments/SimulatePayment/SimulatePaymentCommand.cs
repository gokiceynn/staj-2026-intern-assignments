using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Payments.SimulatePayment;
public sealed record SimulatePaymentCommand(decimal Amount, PaymentCardInput PaymentCard);
public sealed record SimulatePaymentResult(string TransactionId, string Status, DateTime ProcessedAtUtc);
