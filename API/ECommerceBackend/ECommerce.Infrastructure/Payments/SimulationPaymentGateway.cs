using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Infrastructure.Payments;
public sealed class SimulationPaymentGateway(IIdGenerator ids) : IPaymentGateway
{
    public Task<PaymentGatewayResult> ProcessAsync(decimal amount, string currency, PaymentCardInput card, CancellationToken ct)
    {
        bool success = card.Cvv != "000";
        string brand = card.CardNumber.StartsWith('4') ? "Visa" : card.CardNumber.StartsWith('5') ? "Mastercard" : "Unknown";
        return Task.FromResult(new PaymentGatewayResult(success, ids.NewId("txn"), brand, card.CardNumber[^4..], success ? null : "PAYMENT_DECLINED"));
    }
}
