using ECommerce.Application.Features.Catalog;

namespace ECommerce.Application.Features.Orders;

public sealed record ShippingAddressDto(string AddressLine, string City, string District, string ZipCode, string PhoneNumber);
public sealed record OrderItemDto(string ProductId, string ProductTitle, string SellerId, decimal Price, int Quantity, string? PhotoId);
public sealed record CarrierDto(string Id, string Name, string Code);
public sealed record ShipmentDto(string? ShipmentId, string Status, CarrierDto? Carrier, string? TrackingNumber, string? TrackingUrl, DateTime? ShippedAtUtc, DateTime? DeliveredAtUtc);
public sealed record OrderPackageDto(string PackageId, SellerSummary Seller, string Status, decimal Subtotal, decimal? ShippingFee, IReadOnlyList<OrderItemDto> Items, ShipmentDto Shipment);
public sealed record OrderDetailDto(string OrderId, string OrderNumber, decimal Subtotal, decimal ShippingAmount, decimal TotalAmount,
    string Currency, string Status, DateTime CreatedAtUtc, ShippingAddressDto ShippingAddress, string? TrackingNumber,
    string? TrackingUrl, IReadOnlyList<OrderItemDto> Items, IReadOnlyList<OrderPackageDto> Packages);
public sealed record OrderListItemDto(string OrderId, string OrderNumber, decimal TotalAmount, string Currency, string Status, DateTime CreatedAtUtc, int ItemCount, int PackageCount);
public sealed record CancelOrderResult(string OrderId, string Status, DateTime CancelledAtUtc);
