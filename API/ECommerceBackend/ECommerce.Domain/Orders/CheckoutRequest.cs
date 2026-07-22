using ECommerce.Domain.Common;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Identity;

namespace ECommerce.Domain.Orders;

public sealed class CheckoutRequest : EntityBase
{
    public string CustomerAccountId { get; set; } = string.Empty;
    public Account CustomerAccount { get; set; } = null!;
    public string Endpoint { get; set; } = string.Empty;
    public string IdempotencyKey { get; set; } = string.Empty;
    public string RequestHash { get; set; } = string.Empty;
    public CheckoutRequestStatus Status { get; set; }
    public string? OrderId { get; set; }
    public Order? Order { get; set; }
    public int? ResponseStatusCode { get; set; }
    public string? ResponseJson { get; set; }
    public string? FailureCode { get; set; }
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime? CompletedAtUtc { get; set; }
}
