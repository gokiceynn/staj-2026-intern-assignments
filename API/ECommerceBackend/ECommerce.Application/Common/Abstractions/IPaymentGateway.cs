using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Common.Abstractions;
public interface IPaymentGateway { Task<PaymentGatewayResult> ProcessAsync(decimal amount, string currency, PaymentCardInput card, CancellationToken ct); }
