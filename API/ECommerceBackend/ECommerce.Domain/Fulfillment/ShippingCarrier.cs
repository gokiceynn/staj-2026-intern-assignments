using ECommerce.Domain.Common;
using ECommerce.Domain.Media;

namespace ECommerce.Domain.Fulfillment;

public sealed class ShippingCarrier : EntityBase
{
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string? LogoPhotoId { get; set; }
    public Photo? LogoPhoto { get; set; }
    public decimal FlatFee { get; set; }
    public int EstimatedDeliveryDays { get; set; }
    public string TrackingUrlTemplate { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime? DeactivatedAtUtc { get; set; }
    public ICollection<Shipment> Shipments { get; set; } = new List<Shipment>();
}
