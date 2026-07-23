namespace ECommerce.Application.Features.SellerProfile;
public sealed record SellerProfileDto(string Id, string StoreName, string Description, string? LogoId, string TaxNumber,
    string TaxOffice, decimal Rating, bool IsActive, DateTime CreatedAtUtc);
public sealed record SellerDashboardDto(int ProductCount, int ActiveProductCount, int LowStockProductCount, int TotalOrderCount,
    int PaidPackageCount, int PreparingPackageCount, int ShippedPackageCount, int DeliveredPackageCount,
    int CancelledPackageCount, decimal GrossSalesAmount, string Currency);
