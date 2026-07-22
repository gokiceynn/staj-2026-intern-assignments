namespace ECommerce.Application.Features.SellerOrders.ShipPackage;
public sealed record ShipPackageCommand(string PackageId, string CarrierId, string TrackingNumber);
