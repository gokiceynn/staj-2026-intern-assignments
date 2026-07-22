using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Orders;
using ECommerce.Application.Features.SellerOrders;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Fulfillment;
using ECommerce.Domain.Orders;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Infrastructure.Orders;
public sealed class SellerOrderService(AppDbContext db, ITransactionRunner transactions, IOutboxWriter outbox, IIdGenerator ids, IClock clock) : ISellerOrderService
{
    public async Task<Result<SellerPackagePage>> ListAsync(string accountId, int page, int size, string? status, DateTime? from, DateTime? to, CancellationToken ct)
    {
        string? sellerId = await SellerIdAsync(accountId, ct); if (sellerId is null) return Result<SellerPackagePage>.Failure(CommonErrors.NotFound);
        var source = db.OrderPackages.AsNoTracking().Where(x => x.SellerProfileId == sellerId);
        if (Enum.TryParse(status, true, out PackageStatus parsed)) source = source.Where(x => x.Status == parsed);
        if (from.HasValue) source = source.Where(x => x.CreatedAtUtc >= from.Value); if (to.HasValue) source = source.Where(x => x.CreatedAtUtc < to.Value.AddDays(1));
        long total = await source.LongCountAsync(ct);
        var items = await source.OrderByDescending(x => x.CreatedAtUtc).Skip((page - 1) * size).Take(size)
            .Select(x => new SellerPackageListItem(x.Id, x.OrderId, x.Order.OrderNumber, x.Status.ToString(), x.Items.Count,
                x.Subtotal, x.ShippingFee, x.Order.CustomerAccount.FirstName + " " + x.Order.CustomerAccount.LastName, x.CreatedAtUtc)).ToListAsync(ct);
        return Result<SellerPackagePage>.Success(new(new PagedResult<SellerPackageListItem>(items, page, size, total)));
    }

    public async Task<Result<SellerPackageDetail>> GetAsync(string accountId, string packageId, CancellationToken ct)
    {
        string? sellerId = await SellerIdAsync(accountId, ct); if (sellerId is null) return Result<SellerPackageDetail>.Failure(CommonErrors.NotFound);
        OrderPackage? package = await LoadAsync(sellerId, packageId, ct);
        return package is null ? Result<SellerPackageDetail>.Failure(CommonErrors.NotFound) : Result<SellerPackageDetail>.Success(MapDetail(package));
    }

    public Task<Result<PackageTransitionResult>> PrepareAsync(string accountId, string packageId, CancellationToken ct) =>
        TransitionAsync(accountId, packageId, PackageStatus.Paid, async (package, token) =>
        { package.Status = PackageStatus.Preparing; await RecalculateOrderStatusAsync(package.Order, token); }, ct);

    public Task<Result<PackageTransitionResult>> ShipAsync(string accountId, string packageId, string carrierId, string trackingNumber, CancellationToken ct) =>
        TransitionAsync(accountId, packageId, PackageStatus.Preparing, async (package, token) =>
        {
            var carrier = await db.ShippingCarriers.SingleOrDefaultAsync(x => x.Id == carrierId, token);
            if (carrier is null) throw new TransitionException(CommonErrors.NotFound);
            if (!carrier.IsActive) throw new TransitionException(new Error("CARRIER_INACTIVE", "The carrier is inactive."));
            string trackingUrl = carrier.TrackingUrlTemplate.Replace("{trackingNumber}", Uri.EscapeDataString(trackingNumber), StringComparison.Ordinal);
            package.Shipment = new Shipment { Id = ids.NewId("shp"), OrderPackageId = package.Id, ShippingCarrierId = carrier.Id,
                Status = ShipmentStatus.InTransit, TrackingNumber = trackingNumber, TrackingUrl = trackingUrl,
                ShippedAtUtc = clock.UtcNow, CreatedAtUtc = clock.UtcNow, ShippingCarrier = carrier };
            package.Status = PackageStatus.Shipped; package.ShippingFee = carrier.FlatFee;
            await RecalculateOrderStatusAsync(package.Order, token);
        }, ct);

    public Task<Result<PackageTransitionResult>> DeliverAsync(string accountId, string packageId, CancellationToken ct) =>
        TransitionAsync(accountId, packageId, PackageStatus.Shipped, async (package, token) =>
        {
            if (package.Shipment is null) throw new TransitionException(new Error("SHIPMENT_NOT_FOUND", "Shipment was not created."));
            package.Shipment.Status = ShipmentStatus.Delivered; package.Shipment.DeliveredAtUtc = clock.UtcNow;
            package.Status = PackageStatus.Delivered; await RecalculateOrderStatusAsync(package.Order, token);
        }, ct);

    private Task<Result<PackageTransitionResult>> TransitionAsync(string accountId, string packageId, PackageStatus expected,
        Func<OrderPackage, CancellationToken, Task> transition, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            string? sellerId = await SellerIdAsync(accountId, token); if (sellerId is null) return Result<PackageTransitionResult>.Failure(CommonErrors.NotFound);
            _ = await db.OrderPackages.FromSqlInterpolated($"SELECT * FROM order_packages WHERE id = {packageId} FOR UPDATE").SingleOrDefaultAsync(token);
            OrderPackage? package = await db.OrderPackages.Include(x => x.Order).ThenInclude(x => x.Packages)
                .Include(x => x.Shipment).ThenInclude(x => x!.ShippingCarrier)
                .SingleOrDefaultAsync(x => x.Id == packageId && x.SellerProfileId == sellerId, token);
            if (package is null) return Result<PackageTransitionResult>.Failure(CommonErrors.NotFound);
            if (package.Status != expected) return Result<PackageTransitionResult>.Failure(new Error("INVALID_PACKAGE_TRANSITION", $"Package must be {expected}."));
            try { await transition(package, token); }
            catch (TransitionException ex) { return Result<PackageTransitionResult>.Failure(ex.Error); }
            outbox.Add("PackageStatusChanged", new { packageId = package.Id, orderId = package.OrderId, status = package.Status.ToString() });
            await db.SaveChangesAsync(token); return Result<PackageTransitionResult>.Success(MapTransition(package));
        }, System.Data.IsolationLevel.Serializable, ct);

    private async Task RecalculateOrderStatusAsync(Order order, CancellationToken ct)
    {
        PackageStatus[] states = order.Packages.Select(x => x.Status).ToArray();
        order.Status = OrderStatusCalculator.Calculate(states);
        order.UpdatedAtUtc = clock.UtcNow; await Task.CompletedTask;
    }

    private Task<string?> SellerIdAsync(string accountId, CancellationToken ct) => db.SellerProfiles.Where(x => x.AccountId == accountId && x.IsActive).Select(x => x.Id).SingleOrDefaultAsync(ct);
    private Task<OrderPackage?> LoadAsync(string sellerId, string packageId, CancellationToken ct) => db.OrderPackages.AsNoTracking()
        .Include(x => x.Order).ThenInclude(x => x.CustomerAccount).Include(x => x.Items)
        .Include(x => x.Shipment).ThenInclude(x => x!.ShippingCarrier)
        .SingleOrDefaultAsync(x => x.Id == packageId && x.SellerProfileId == sellerId, ct);
    private static SellerPackageDetail MapDetail(OrderPackage p) => new(p.Id, p.OrderId, p.Order.OrderNumber, p.Status.ToString(), p.CreatedAtUtc,
        new SellerCustomerDto(p.Order.CustomerAccount.FirstName + " " + p.Order.CustomerAccount.LastName, p.Order.CustomerAccount.PhoneNumber),
        JsonSerializer.Deserialize<ShippingAddressDto>(p.Order.ShippingAddressJson)!, p.Subtotal, p.ShippingFee,
        p.Items.Select(i => new OrderItemDto(i.ProductId, i.ProductTitleSnapshot, i.SellerProfileId, i.UnitPrice, i.Quantity, i.PhotoIdSnapshot)).ToList(), MapShipment(p));
    private static PackageTransitionResult MapTransition(OrderPackage p) => new(p.Id, p.OrderId, p.Status.ToString(), p.ShippingFee, MapShipment(p));
    private static ShipmentDto MapShipment(OrderPackage p) => p.Shipment is null
        ? new(null, ShipmentStatus.NotCreated.ToString(), null, null, null, null, null)
        : new(p.Shipment.Id, p.Shipment.Status.ToString(), new CarrierDto(p.Shipment.ShippingCarrier.Id, p.Shipment.ShippingCarrier.Name, p.Shipment.ShippingCarrier.Code),
            p.Shipment.TrackingNumber, p.Shipment.TrackingUrl, p.Shipment.ShippedAtUtc, p.Shipment.DeliveredAtUtc);
    private sealed class TransitionException(Error error) : Exception { public Error Error { get; } = error; }
}
