using ECommerce.Domain.Common;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Identity;

namespace ECommerce.Domain.Orders;

public sealed class Order : EntityBase
{
    public string CustomerAccountId { get; set; } = string.Empty;
    public Account CustomerAccount { get; set; } = null!;
    public string OrderNumber { get; set; } = string.Empty;
    public decimal Subtotal { get; set; }
    public decimal ShippingAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public string Currency { get; set; } = "TRY";
    public OrderStatus Status { get; set; }
    public string ShippingAddressJson { get; set; } = "{}";
    public string? CancelReason { get; set; }
    public DateTime? CancelledAtUtc { get; set; }
    public DateTime? StockReturnedAtUtc { get; set; }
    public ICollection<OrderItem> Items { get; set; } = new List<OrderItem>();
    public ICollection<OrderPackage> Packages { get; set; } = new List<OrderPackage>();
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
