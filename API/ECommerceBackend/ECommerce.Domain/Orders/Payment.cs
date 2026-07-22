using ECommerce.Domain.Common;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Identity;

namespace ECommerce.Domain.Orders;

public sealed class Payment : EntityBase
{
    public string CustomerAccountId { get; set; } = string.Empty;
    public Account CustomerAccount { get; set; } = null!;
    public string? OrderId { get; set; }
    public Order? Order { get; set; }
    public string Provider { get; set; } = "Simulation";
    public string ProviderTransactionId { get; set; } = string.Empty;
    public PaymentStatus Status { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "TRY";
    public string? CardBrand { get; set; }
    public string? CardLast4 { get; set; }
    public string? FailureCode { get; set; }
    public DateTime ProcessedAtUtc { get; set; }
}
