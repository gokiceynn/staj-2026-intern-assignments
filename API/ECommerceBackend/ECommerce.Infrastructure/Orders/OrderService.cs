using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Catalog;
using ECommerce.Application.Features.Orders;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Orders;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Infrastructure.Orders;
public sealed class OrderService(
    AppDbContext db, ITransactionRunner transactions, IPaymentGateway paymentGateway,
    IOutboxWriter outbox, IIdGenerator ids, IClock clock) : IOrderService
{
    public Task<Result<OrderDetailDto>> CheckoutAsync(
        string accountId, string addressId, PaymentCardInput card, string idempotencyKey, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            var cart = await db.Carts.AsNoTracking().Where(x => x.CustomerAccountId == accountId && x.IsActive)
                .Select(x => new { x.Id, Items = x.Items.Select(i => new { i.ProductId, i.Quantity }).ToList() }).SingleOrDefaultAsync(token);
            if (cart is null || cart.Items.Count == 0) return Result<OrderDetailDto>.Failure(new Error("CART_EMPTY", "The cart is empty."));
            string requestHash = Sha256(JsonSerializer.Serialize(new { addressId, items = cart.Items.OrderBy(x => x.ProductId) }));
            string checkoutId = ids.NewId("chk"); DateTime now = clock.UtcNow;
            int inserted = await db.Database.ExecuteSqlInterpolatedAsync($@"
                INSERT IGNORE INTO checkout_requests
                (id, customer_account_id, endpoint, idempotency_key, request_hash, status, expires_at_utc, created_at_utc, version)
                VALUES ({checkoutId}, {accountId}, {'/' + "orders/checkout"}, {idempotencyKey}, {requestHash},
                        {(int)CheckoutRequestStatus.Processing}, {now.AddHours(24)}, {now}, {1})", token);
            CheckoutRequest request = await db.CheckoutRequests
                .FromSqlInterpolated($"SELECT * FROM checkout_requests WHERE customer_account_id = {accountId} AND endpoint = {'/' + "orders/checkout"} AND idempotency_key = {idempotencyKey} FOR UPDATE")
                .SingleAsync(token);
            if (request.RequestHash != requestHash)
                return Result<OrderDetailDto>.Failure(new Error("IDEMPOTENCY_KEY_REUSED", "The idempotency key was used with a different request."));
            if (inserted == 0 && request.Status == CheckoutRequestStatus.Completed && request.ResponseJson is not null)
                return Result<OrderDetailDto>.Success(JsonSerializer.Deserialize<OrderDetailDto>(request.ResponseJson)!);
            if (inserted == 0 && request.Status == CheckoutRequestStatus.Failed)
                return Result<OrderDetailDto>.Failure(new Error(request.FailureCode ?? "CHECKOUT_FAILED", "The previous checkout attempt failed."));

            var address = await db.Addresses.AsNoTracking().SingleOrDefaultAsync(x => x.Id == addressId && x.AccountId == accountId && x.IsActive, token);
            if (address is null) return Result<OrderDetailDto>.Failure(CommonErrors.NotFound);
            List<string> productIds = cart.Items.Select(x => x.ProductId).OrderBy(x => x, StringComparer.Ordinal).ToList();
            foreach (string productId in productIds)
                _ = await db.Products.FromSqlInterpolated($"SELECT * FROM products WHERE id = {productId} FOR UPDATE").SingleOrDefaultAsync(token);
            var products = await db.Products.Include(x => x.SellerProfile).Include(x => x.Photos)
                .Where(x => productIds.Contains(x.Id) && x.IsActive && x.SellerProfile.IsActive).ToListAsync(token);
            if (products.Count != productIds.Count) return Result<OrderDetailDto>.Failure(new Error("PRODUCT_UNAVAILABLE", "One or more products are unavailable."));
            if (products.Any(p => p.Stock < cart.Items.Single(x => x.ProductId == p.Id).Quantity))
                return Result<OrderDetailDto>.Failure(new Error("INSUFFICIENT_STOCK", "One or more products have insufficient stock."));

            decimal subtotal = products.Sum(p => p.Price * cart.Items.Single(x => x.ProductId == p.Id).Quantity);
            PaymentGatewayResult payment = await paymentGateway.ProcessAsync(subtotal, "TRY", card, token);
            if (!payment.IsSuccess)
            {
                request.Status = CheckoutRequestStatus.Failed; request.FailureCode = payment.FailureCode ?? "PAYMENT_DECLINED";
                request.ResponseStatusCode = 422; request.CompletedAtUtc = now; await db.SaveChangesAsync(token);
                return Result<OrderDetailDto>.Failure(new Error("PAYMENT_DECLINED", "The payment was declined."));
            }

            foreach (var product in products) product.Stock -= cart.Items.Single(x => x.ProductId == product.Id).Quantity;

            ShippingAddressDto shipping = new(address.AddressLine, address.City, address.District, address.ZipCode, address.PhoneNumber);
            Order order = new()
            {
                Id = ids.NewId("ord"), CustomerAccountId = accountId, OrderNumber = NewOrderNumber(now),
                Subtotal = subtotal, ShippingAmount = 0, TotalAmount = subtotal, Currency = "TRY", Status = OrderStatus.Paid,
                ShippingAddressJson = JsonSerializer.Serialize(shipping), CreatedAtUtc = now
            };
            foreach (var sellerGroup in products.GroupBy(x => x.SellerProfileId))
            {
                var seller = sellerGroup.First().SellerProfile;
                OrderPackage package = new() { Id = ids.NewId("pkg"), OrderId = order.Id, SellerProfileId = seller.Id,
                    SellerStoreNameSnapshot = seller.StoreName, Status = PackageStatus.Paid, CreatedAtUtc = now };
                foreach (var product in sellerGroup)
                {
                    int quantity = cart.Items.Single(x => x.ProductId == product.Id).Quantity;
                    OrderItem item = new() { Id = ids.NewId("itm"), OrderId = order.Id, OrderPackageId = package.Id,
                        ProductId = product.Id, SellerProfileId = seller.Id, ProductTitleSnapshot = product.Title,
                        SellerNameSnapshot = seller.StoreName, PhotoIdSnapshot = product.Photos.OrderBy(x => x.DisplayOrder).Select(x => x.PhotoId).FirstOrDefault(),
                        UnitPrice = product.Price, Quantity = quantity, TotalPrice = product.Price * quantity, CreatedAtUtc = now };
                    package.Items.Add(item); order.Items.Add(item); package.Subtotal += item.TotalPrice;
                }
                order.Packages.Add(package);
            }
            Payment paymentEntity = new() { Id = ids.NewId("pay"), CustomerAccountId = accountId, OrderId = order.Id,
                Provider = "Simulation", ProviderTransactionId = payment.TransactionId, Status = PaymentStatus.Success,
                Amount = subtotal, Currency = "TRY", CardBrand = payment.CardBrand, CardLast4 = payment.CardLast4,
                ProcessedAtUtc = now, CreatedAtUtc = now };
            order.Payments.Add(paymentEntity); db.Orders.Add(order);
            await db.CartItems.Where(x => x.CartId == cart.Id).ExecuteDeleteAsync(token);
            OrderDetailDto response = MapNew(order, shipping);
            request.Status = CheckoutRequestStatus.Completed; request.OrderId = order.Id; request.ResponseStatusCode = 200;
            request.ResponseJson = JsonSerializer.Serialize(response); request.CompletedAtUtc = now;
            outbox.Add("OrderCreated", new { orderId = order.Id, accountId, orderNumber = order.OrderNumber });
            await db.SaveChangesAsync(token);
            return Result<OrderDetailDto>.Success(response);
        }, System.Data.IsolationLevel.Serializable, ct);

    public async Task<Result<OrderDetailDto>> GetCustomerOrderAsync(string accountId, string orderId, CancellationToken ct)
    {
        Order? order = await db.Orders.AsNoTracking().Include(x => x.Items)
            .Include(x => x.Packages).ThenInclude(x => x.Items)
            .Include(x => x.Packages).ThenInclude(x => x.SellerProfile)
            .Include(x => x.Packages).ThenInclude(x => x.Shipment).ThenInclude(x => x!.ShippingCarrier)
            .SingleOrDefaultAsync(x => x.Id == orderId && x.CustomerAccountId == accountId, ct);
        return order is null ? Result<OrderDetailDto>.Failure(CommonErrors.NotFound) : Result<OrderDetailDto>.Success(MapExisting(order));
    }

    public Task<Result<CancelOrderResult>> CancelAsync(string accountId, string orderId, string reason, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            Order? order = await db.Orders.FromSqlInterpolated($"SELECT * FROM orders WHERE id = {orderId} AND customer_account_id = {accountId} FOR UPDATE")
                .Include(x => x.Items).Include(x => x.Packages).SingleOrDefaultAsync(token);
            if (order is null) return Result<CancelOrderResult>.Failure(CommonErrors.NotFound);
            if (order.Status == OrderStatus.Cancelled)
                return Result<CancelOrderResult>.Success(new(order.Id, order.Status.ToString(), order.CancelledAtUtc!.Value));
            if (order.Packages.Any(x => x.Status is PackageStatus.Shipped or PackageStatus.Delivered))
                return Result<CancelOrderResult>.Failure(new Error("ORDER_CANNOT_BE_CANCELLED", "A shipped or delivered order cannot be cancelled."));
            DateTime now = clock.UtcNow;
            if (order.StockReturnedAtUtc is null)
            {
                foreach (var item in order.Items.OrderBy(x => x.ProductId, StringComparer.Ordinal))
                    await db.Products.Where(x => x.Id == item.ProductId)
                        .ExecuteUpdateAsync(x => x.SetProperty(p => p.Stock, p => p.Stock + item.Quantity), token);
                order.StockReturnedAtUtc = now;
            }
            foreach (var package in order.Packages) { package.Status = PackageStatus.Cancelled; package.CancelledAtUtc = now; }
            order.Status = OrderStatus.Cancelled; order.CancelReason = reason; order.CancelledAtUtc = now; order.UpdatedAtUtc = now;
            outbox.Add("OrderCancelled", new { orderId = order.Id, accountId, reason }); await db.SaveChangesAsync(token);
            return Result<CancelOrderResult>.Success(new(order.Id, order.Status.ToString(), now));
        }, System.Data.IsolationLevel.Serializable, ct);

    private static OrderDetailDto MapNew(Order order, ShippingAddressDto address)
    {
        List<OrderPackageDto> packages = order.Packages.Select(p => new OrderPackageDto(p.Id,
            new SellerSummary(p.SellerProfileId, p.SellerStoreNameSnapshot, null, 0), p.Status.ToString(), p.Subtotal, p.ShippingFee,
            p.Items.Select(MapItem).ToList(), new ShipmentDto(null, ShipmentStatus.NotCreated.ToString(), null, null, null, null, null))).ToList();
        return new(order.Id, order.OrderNumber, order.Subtotal, order.ShippingAmount, order.TotalAmount, order.Currency,
            order.Status.ToString(), order.CreatedAtUtc, address, null, null, order.Items.Select(MapItem).ToList(), packages);
    }
    private static OrderDetailDto MapExisting(Order order)
    {
        ShippingAddressDto address = JsonSerializer.Deserialize<ShippingAddressDto>(order.ShippingAddressJson)!;
        List<OrderPackageDto> packages = order.Packages.Select(p => new OrderPackageDto(p.Id,
            new SellerSummary(p.SellerProfileId, p.SellerStoreNameSnapshot, p.SellerProfile.LogoPhotoId, p.SellerProfile.RatingAverage),
            p.Status.ToString(), p.Subtotal, p.ShippingFee, p.Items.Select(MapItem).ToList(), MapShipment(p))).ToList();
        var first = packages.Count == 1 ? packages[0].Shipment : null;
        return new(order.Id, order.OrderNumber, order.Subtotal, order.ShippingAmount, order.TotalAmount, order.Currency,
            order.Status.ToString(), order.CreatedAtUtc, address, first?.TrackingNumber, first?.TrackingUrl,
            order.Items.Select(MapItem).ToList(), packages);
    }
    private static ShipmentDto MapShipment(OrderPackage package) => package.Shipment is null
        ? new(null, ShipmentStatus.NotCreated.ToString(), null, null, null, null, null)
        : new(package.Shipment.Id, package.Shipment.Status.ToString(),
            new CarrierDto(package.Shipment.ShippingCarrier.Id, package.Shipment.ShippingCarrier.Name, package.Shipment.ShippingCarrier.Code),
            package.Shipment.TrackingNumber, package.Shipment.TrackingUrl, package.Shipment.ShippedAtUtc, package.Shipment.DeliveredAtUtc);
    private static OrderItemDto MapItem(OrderItem i) => new(i.ProductId, i.ProductTitleSnapshot, i.SellerProfileId, i.UnitPrice, i.Quantity, i.PhotoIdSnapshot);
    private static string Sha256(string value) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(value))).ToLowerInvariant();
    private static string NewOrderNumber(DateTime now) => $"ORD-{now:yyyy-MMdd}-{Convert.ToHexString(RandomNumberGenerator.GetBytes(3))}";
}
