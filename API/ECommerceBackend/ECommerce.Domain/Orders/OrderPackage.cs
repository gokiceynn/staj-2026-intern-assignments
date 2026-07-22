using ECommerce.Domain.Common;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Fulfillment;
using ECommerce.Domain.Profiles;

namespace ECommerce.Domain.Orders;

public sealed class OrderPackage : EntityBase
{
    public string OrderId { get; set; } = string.Empty;
    public Order Order { get; set; } = null!;
    public string SellerProfileId { get; set; } = string.Empty;
    public SellerProfile SellerProfile { get; set; } = null!;
    public string SellerStoreNameSnapshot { get; set; } = string.Empty;
    public PackageStatus Status { get; set; }
    public decimal Subtotal { get; set; }
    public decimal? ShippingFee { get; set; }
    public DateTime? CancelledAtUtc { get; set; }
    public ICollection<OrderItem> Items { get; set; } = new List<OrderItem>();
    public Shipment? Shipment { get; set; }
}
