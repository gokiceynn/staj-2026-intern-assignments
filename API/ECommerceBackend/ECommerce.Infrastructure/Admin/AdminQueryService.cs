using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
using ECommerce.Application.Features.Catalog;
using ECommerce.Application.Features.Orders;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Identity;
using ECommerce.Domain.Orders;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Infrastructure.Admin;

public sealed class AdminQueryService(AppDbContext db) : IAdminQueryService
{
    public async Task<Result<AdminDashboardDto>> GetDashboardAsync(
        DateTime? from,
        DateTime? to,
        CancellationToken ct
    )
    {
        var orders = db.Orders.AsNoTracking();
        if (from.HasValue)
            orders = orders.Where(x => x.CreatedAtUtc >= from.Value);
        if (to.HasValue)
            orders = orders.Where(x => x.CreatedAtUtc < to.Value.AddDays(1));
        return Result<AdminDashboardDto>.Success(
            new(
                await db.Accounts.CountAsync(ct),
                await db.Accounts.CountAsync(x => x.Role.Code == "Customer", ct),
                await db.Accounts.CountAsync(x => x.Role.Code == "Seller", ct),
                await db.Products.CountAsync(x => x.IsActive, ct),
                await orders.CountAsync(ct),
                await orders
                    .Where(x => x.Status != OrderStatus.Cancelled)
                    .SumAsync(x => x.TotalAmount, ct),
                "TRY"
            )
        );
    }

    public async Task<Result<PagedResult<AdminUserListItem>>> ListUsersAsync(
        int page,
        int size,
        string? q,
        string? role,
        bool? active,
        CancellationToken ct
    )
    {
        IQueryable<Account> source = db.Accounts.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(q))
            source = source.Where(x =>
                EF.Functions.Like(x.Email, $"%{q.Trim()}%")
                || EF.Functions.Like(x.FirstName, $"%{q.Trim()}%")
            );
        if (!string.IsNullOrWhiteSpace(role))
            source = source.Where(x => x.Role.Code == role);
        if (active.HasValue)
            source = source.Where(x => x.IsActive == active.Value);
        long total = await source.LongCountAsync(ct);
        var items = await source
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((page - 1) * size)
            .Take(size)
            .Select(x => new AdminUserListItem(
                x.Id,
                x.Email,
                x.FirstName + " " + x.LastName,
                x.Role.Code,
                x.IsActive,
                x.IsEmailVerified,
                x.CreatedAtUtc
            ))
            .ToListAsync(ct);
        return Result<PagedResult<AdminUserListItem>>.Success(new(items, page, size, total));
    }

    public async Task<Result<AdminUserDetail>> GetUserAsync(string id, CancellationToken ct)
    {
        AdminUserDetail? x = await db
            .Accounts.AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new AdminUserDetail(
                x.Id,
                x.Email,
                x.FirstName,
                x.LastName,
                x.PhoneNumber,
                x.Role.Code,
                x.IsActive,
                x.IsEmailVerified,
                x.SecurityVersion,
                x.CreatedAtUtc,
                x.LastLoginAtUtc
            ))
            .SingleOrDefaultAsync(ct);
        return x is null
            ? Result<AdminUserDetail>.Failure(CommonErrors.NotFound)
            : Result<AdminUserDetail>.Success(x);
    }

    public async Task<Result<PagedResult<AdminSellerListItem>>> ListSellersAsync(
        int page,
        int size,
        string? q,
        bool? active,
        CancellationToken ct
    )
    {
        var source = db.SellerProfiles.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(q))
            source = source.Where(x => EF.Functions.Like(x.StoreName, $"%{q.Trim()}%"));
        if (active.HasValue)
            source = source.Where(x => x.IsActive == active.Value);
        long total = await source.LongCountAsync(ct);
        var items = await source
            .OrderBy(x => x.StoreName)
            .Skip((page - 1) * size)
            .Take(size)
            .Select(x => new AdminSellerListItem(
                x.Id,
                x.AccountId,
                x.StoreName,
                x.Account.Email,
                x.RatingAverage,
                x.IsActive,
                x.Products.Count
            ))
            .ToListAsync(ct);
        return Result<PagedResult<AdminSellerListItem>>.Success(new(items, page, size, total));
    }

    public async Task<Result<AdminSellerDetail>> GetSellerAsync(string id, CancellationToken ct)
    {
        AdminSellerDetail? x = await db
            .SellerProfiles.AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new AdminSellerDetail(
                x.Id,
                x.AccountId,
                x.StoreName,
                x.Description,
                x.TaxNumber,
                x.TaxOffice,
                x.LogoPhotoId,
                x.RatingAverage,
                x.IsActive,
                x.Products.Count,
                x.CreatedAtUtc
            ))
            .SingleOrDefaultAsync(ct);
        return x is null
            ? Result<AdminSellerDetail>.Failure(CommonErrors.NotFound)
            : Result<AdminSellerDetail>.Success(x);
    }

    public async Task<Result<PagedResult<AdminOrderListItem>>> ListOrdersAsync(
        int page,
        int size,
        string? status,
        DateTime? from,
        DateTime? to,
        CancellationToken ct
    )
    {
        var source = db.Orders.AsNoTracking();
        if (Enum.TryParse(status, true, out OrderStatus parsed))
            source = source.Where(x => x.Status == parsed);
        if (from.HasValue)
            source = source.Where(x => x.CreatedAtUtc >= from.Value);
        if (to.HasValue)
            source = source.Where(x => x.CreatedAtUtc < to.Value.AddDays(1));
        long total = await source.LongCountAsync(ct);
        var items = await source
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((page - 1) * size)
            .Take(size)
            .Select(x => new AdminOrderListItem(
                x.Id,
                x.OrderNumber,
                x.CustomerAccount.Email,
                x.TotalAmount,
                x.Currency,
                x.Status.ToString(),
                x.Packages.Count,
                x.CreatedAtUtc
            ))
            .ToListAsync(ct);
        return Result<PagedResult<AdminOrderListItem>>.Success(new(items, page, size, total));
    }

    public async Task<Result<AdminOrderDetail>> GetOrderAsync(string id, CancellationToken ct)
    {
        Order? order = await db
            .Orders.AsNoTracking()
            .Include(x => x.CustomerAccount)
            .Include(x => x.Items)
            .Include(x => x.Packages)
                .ThenInclude(x => x.Items)
            .Include(x => x.Packages)
                .ThenInclude(x => x.SellerProfile)
            .Include(x => x.Packages)
                .ThenInclude(x => x.Shipment)
                    .ThenInclude(x => x!.ShippingCarrier)
            .SingleOrDefaultAsync(x => x.Id == id, ct);
        if (order is null)
            return Result<AdminOrderDetail>.Failure(CommonErrors.NotFound);
        ShippingAddressDto address = JsonSerializer.Deserialize<ShippingAddressDto>(
            order.ShippingAddressJson
        )!;
        List<OrderPackageDto> packages = order
            .Packages.Select(p => new OrderPackageDto(
                p.Id,
                new SellerSummary(
                    p.SellerProfileId,
                    p.SellerStoreNameSnapshot,
                    p.SellerProfile.LogoPhotoId,
                    p.SellerProfile.RatingAverage
                ),
                p.Status.ToString(),
                p.Subtotal,
                p.ShippingFee,
                p.Items.Select(Item).ToList(),
                p.Shipment is null
                    ? new ShipmentDto(null, "NotCreated", null, null, null, null, null)
                    : new ShipmentDto(
                        p.Shipment.Id,
                        p.Shipment.Status.ToString(),
                        new CarrierDto(
                            p.Shipment.ShippingCarrier.Id,
                            p.Shipment.ShippingCarrier.Name,
                            p.Shipment.ShippingCarrier.Code
                        ),
                        p.Shipment.TrackingNumber,
                        p.Shipment.TrackingUrl,
                        p.Shipment.ShippedAtUtc,
                        p.Shipment.DeliveredAtUtc
                    )
            ))
            .ToList();
        OrderDetailDto dto = new(
            order.Id,
            order.OrderNumber,
            order.Subtotal,
            order.ShippingAmount,
            order.TotalAmount,
            order.Currency,
            order.Status.ToString(),
            order.CreatedAtUtc,
            address,
            packages.Count == 1 ? packages[0].Shipment.TrackingNumber : null,
            packages.Count == 1 ? packages[0].Shipment.TrackingUrl : null,
            order.Items.Select(Item).ToList(),
            packages
        );
        return Result<AdminOrderDetail>.Success(new(dto, order.CustomerAccount.Email));
    }

    public async Task<Result<IReadOnlyList<AdminShippingCarrierDto>>> ListCarriersAsync(
        CancellationToken ct
    ) =>
        Result<IReadOnlyList<AdminShippingCarrierDto>>.Success(
            await db
                .ShippingCarriers.AsNoTracking()
                .OrderBy(x => x.Name)
                .Select(MapCarrier)
                .ToListAsync(ct)
        );

    public async Task<Result<AdminShippingCarrierDto>> GetCarrierAsync(
        string id,
        CancellationToken ct
    )
    {
        var x = await db
            .ShippingCarriers.AsNoTracking()
            .Where(x => x.Id == id)
            .Select(MapCarrier)
            .SingleOrDefaultAsync(ct);
        return x is null
            ? Result<AdminShippingCarrierDto>.Failure(CommonErrors.NotFound)
            : Result<AdminShippingCarrierDto>.Success(x);
    }

    private static readonly System.Linq.Expressions.Expression<
        Func<ECommerce.Domain.Fulfillment.ShippingCarrier, AdminShippingCarrierDto>
    > MapCarrier = x =>
        new(
            x.Id,
            x.Name,
            x.Code,
            x.LogoPhotoId,
            x.FlatFee,
            x.EstimatedDeliveryDays,
            x.TrackingUrlTemplate,
            x.IsActive,
            x.CreatedAtUtc,
            x.UpdatedAtUtc
        );

    private static OrderItemDto Item(OrderItem i) =>
        new(
            i.ProductId,
            i.ProductTitleSnapshot,
            i.SellerProfileId,
            i.UnitPrice,
            i.Quantity,
            i.PhotoIdSnapshot
        );
}

