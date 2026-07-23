using ECommerce.Domain.Catalog;
using ECommerce.Domain.Common;
using ECommerce.Domain.Media;
using ECommerce.Domain.Profiles;

namespace ECommerce.Domain.Orders;

public sealed class OrderItem : EntityBase
{
    public string OrderId { get; set; } = string.Empty;
    public Order Order { get; set; } = null!;
    public string OrderPackageId { get; set; } = string.Empty;
    public OrderPackage OrderPackage { get; set; } = null!;
    public string ProductId { get; set; } = string.Empty;
    public Product Product { get; set; } = null!;
    public string SellerProfileId { get; set; } = string.Empty;
    public SellerProfile SellerProfile { get; set; } = null!;
    public string ProductTitleSnapshot { get; set; } = string.Empty;
    public string SellerNameSnapshot { get; set; } = string.Empty;
    public string? PhotoIdSnapshot { get; set; }
    public Photo? PhotoSnapshot { get; set; }
    public decimal UnitPrice { get; set; }
    public int Quantity { get; set; }
    public decimal TotalPrice { get; set; }
}
