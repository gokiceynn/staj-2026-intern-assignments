using ECommerce.Application.Common.Abstractions;
using ECommerce.Domain.Common;
using ECommerce.Domain.Fulfillment;
using ECommerce.Domain.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace ECommerce.Infrastructure.Persistence.Seed;

public sealed class DatabaseSeeder(
    AppDbContext db,
    IClock clock,
    IIdGenerator ids,
    IPasswordHasher passwordHasher,
    IOptions<AdminSeedOptions> adminOptions,
    ILogger<DatabaseSeeder> logger)
{
    public async Task SeedAsync(CancellationToken ct)
    {
        await SeedRolesAsync(ct);
        await SeedCarriersAsync(ct);
    }

    /// <summary>
    /// İlk admin hesabını oluşturur. Kayıt uçlarından admin açılamadığı için sistemin
    /// admin uçlarına ilk erişim bu yoldan sağlanır. Seed:Admin:Email boşsa hiçbir şey yapmaz;
    /// e-posta zaten kayıtlıysa hesaba dokunmaz (rol yükseltmesi YAPMAZ).
    /// </summary>
    public async Task SeedAdminAsync(CancellationToken ct)
    {
        AdminSeedOptions options = adminOptions.Value;
        if (!options.IsConfigured) return;
        if (string.IsNullOrWhiteSpace(options.Password))
            throw new InvalidOperationException("Seed:Admin:Email verilmiş ancak Seed:Admin:Password boş.");
        if (options.Password.Length < 12)
            throw new InvalidOperationException("Seed:Admin:Password en az 12 karakter olmalıdır.");

        await SeedRolesAsync(ct);

        string normalizedEmail = options.Email.Trim().ToUpperInvariant();
        if (await db.Accounts.AnyAsync(x => x.NormalizedEmail == normalizedEmail, ct))
        {
            logger.LogInformation("Admin seed atlandı: {Email} zaten kayıtlı.", options.Email);
            return;
        }

        Role role = await db.Roles.SingleAsync(x => x.Code == RoleCodes.Admin, ct);
        db.Accounts.Add(new Account
        {
            Id = ids.NewId("usr"),
            Email = options.Email.Trim(),
            NormalizedEmail = normalizedEmail,
            PasswordHash = passwordHasher.Hash(options.Password),
            PasswordHashVersion = 1,
            FirstName = options.FirstName.Trim(),
            LastName = options.LastName.Trim(),
            PhoneNumber = options.PhoneNumber.Trim(),
            RoleId = role.Id,
            CreatedAtUtc = clock.UtcNow,
            IsEmailVerified = true, // OTP akışından geçmez; doğrudan giriş yapabilmelidir
            IsActive = true,
            SecurityVersion = 1
        });
        await db.SaveChangesAsync(ct);
        logger.LogWarning("İlk admin hesabı oluşturuldu: {Email}. İlk girişten sonra parolayı değiştirin.", options.Email);
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
