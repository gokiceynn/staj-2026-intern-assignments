namespace ECommerce.Api.Contracts.V1;
public sealed record UpdateSellerProfileRequest(string StoreName, string Description, string? LogoId, string TaxOffice);
public sealed record SellerProductWriteRequest(string Title, string Description, decimal Price, int Stock, string CategoryId,
    IReadOnlyList<string> PhotoIds, IReadOnlyDictionary<string, string> Features, bool IsActive);
public sealed record ShipPackageRequest(string CarrierId, string TrackingNumber);
