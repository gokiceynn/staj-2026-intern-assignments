using ECommerce.Application.Common.Abstractions;
using ECommerce.Domain.Common;
using ECommerce.Domain.Fulfillment;
using ECommerce.Domain.Identity;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Infrastructure.Persistence.Seed;

public sealed class DatabaseSeeder(AppDbContext db, IClock clock)
{
    public async Task SeedAsync(CancellationToken ct)
    {
        await SeedRolesAsync(ct);
        await SeedCarriersAsync(ct);
    }

    private async Task SeedRolesAsync(CancellationToken ct)
    {
        (string Id, string Code, string Name)[] roles =
        [
            ("rol_customer", RoleCodes.Customer, "Customer"),
            ("rol_seller", RoleCodes.Seller, "Seller"),
            ("rol_admin", RoleCodes.Admin, "Admin")
        ];
        foreach (var item in roles)
            if (!await db.Roles.AnyAsync(x => x.Code == item.Code, ct))
                db.Roles.Add(new Role { Id = item.Id, Code = item.Code, DisplayName = item.Name, IsSystemRole = true, CreatedAtUtc = clock.UtcNow });
        await db.SaveChangesAsync(ct);
    }

    private async Task SeedCarriersAsync(CancellationToken ct)
    {
        if (await db.ShippingCarriers.AnyAsync(ct)) return;
        db.ShippingCarriers.AddRange(
            new ShippingCarrier { Id = "car_yurtici", Code = "YURTICI", Name = "Yurtiçi Kargo", FlatFee = 49.90m, EstimatedDeliveryDays = 3, TrackingUrlTemplate = "https://www.yurticikargo.com/tr/online-servisler/gonderi-sorgula?code={trackingNumber}", IsActive = true, CreatedAtUtc = clock.UtcNow },
            new ShippingCarrier { Id = "car_aras", Code = "ARAS", Name = "Aras Kargo", FlatFee = 44.90m, EstimatedDeliveryDays = 4, TrackingUrlTemplate = "https://kargotakip.araskargo.com.tr/mainpage.aspx?code={trackingNumber}", IsActive = true, CreatedAtUtc = clock.UtcNow });
        await db.SaveChangesAsync(ct);
    }
}
