using ECommerce.Domain.Common;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Orders;

namespace ECommerce.Domain.Fulfillment;

public sealed class Shipment : EntityBase
{
    public string OrderPackageId { get; set; } = string.Empty;
    public OrderPackage OrderPackage { get; set; } = null!;
    public string ShippingCarrierId { get; set; } = string.Empty;
    public ShippingCarrier ShippingCarrier { get; set; } = null!;
    public ShipmentStatus Status { get; set; }
    public string TrackingNumber { get; set; } = string.Empty;
    public string TrackingUrl { get; set; } = string.Empty;
    public DateTime? ShippedAtUtc { get; set; }
    public DateTime? DeliveredAtUtc { get; set; }
    public DateTime? CancelledAtUtc { get; set; }
}
