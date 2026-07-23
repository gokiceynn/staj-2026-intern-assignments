using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Orders;
namespace ECommerce.Application.Features.SellerOrders;
public sealed record SellerPackageListItem(string PackageId, string OrderId, string OrderNumber, string Status, int ItemCount,
    decimal Subtotal, decimal? ShippingFee, string CustomerName, DateTime CreatedAtUtc);
public sealed record SellerCustomerDto(string FullName, string PhoneNumber);
public sealed record SellerPackageDetail(string PackageId, string OrderId, string OrderNumber, string Status, DateTime CreatedAtUtc,
    SellerCustomerDto Customer, ShippingAddressDto ShippingAddress, decimal Subtotal, decimal? ShippingFee,
    IReadOnlyList<OrderItemDto> Items, ShipmentDto Shipment);
public sealed record PackageTransitionResult(string PackageId, string OrderId, string Status, decimal? ShippingFee, ShipmentDto Shipment);
public sealed record SellerPackagePage(PagedResult<SellerPackageListItem> Page);
