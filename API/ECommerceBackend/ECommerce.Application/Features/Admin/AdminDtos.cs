using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Orders;
using ECommerce.Application.Features.SellerShippingCarriers;

namespace ECommerce.Application.Features.Admin;

public sealed record AdminDashboardDto(int UserCount, int CustomerCount, int SellerCount, int ActiveProductCount,
    int OrderCount, decimal GrossSalesAmount, string Currency);
public sealed record AdminUserListItem(string Id, string Email, string FullName, string Role, bool IsActive, bool IsEmailVerified, DateTime CreatedAtUtc);
public sealed record AdminUserDetail(string Id, string Email, string FirstName, string LastName, string PhoneNumber,
    string Role, bool IsActive, bool IsEmailVerified, int SecurityVersion, DateTime CreatedAtUtc, DateTime? LastLoginAtUtc);
public sealed record AdminSellerListItem(string Id, string AccountId, string StoreName, string Email, decimal Rating, bool IsActive, int ProductCount);
public sealed record AdminSellerDetail(string Id, string AccountId, string StoreName, string Description, string TaxNumber,
    string TaxOffice, string? LogoId, decimal Rating, bool IsActive, int ProductCount, DateTime CreatedAtUtc);
public sealed record AdminOrderListItem(string OrderId, string OrderNumber, string CustomerEmail, decimal TotalAmount,
    string Currency, string Status, int PackageCount, DateTime CreatedAtUtc);
public sealed record AdminOrderDetail(OrderDetailDto Order, string CustomerEmail);
public sealed record AdminShippingCarrierDto(string Id, string Name, string Code, string? LogoId, decimal FlatFee,
    int EstimatedDeliveryDays, string TrackingUrlTemplate, bool IsActive, DateTime CreatedAtUtc, DateTime? UpdatedAtUtc);
