using ECommerce.Domain.Orders;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ECommerce.Infrastructure.Persistence.Configurations;

public sealed class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> b)
    {
        b.ToTable("orders"); b.ConfigureEntityBase();
        b.Property(x => x.CustomerAccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.OrderNumber).HasColumnType("varchar(40)").HasMaxLength(40).UseCollation("ascii_bin");
        b.Property(x => x.Subtotal).HasPrecision(18, 2); b.Property(x => x.ShippingAmount).HasPrecision(18, 2); b.Property(x => x.TotalAmount).HasPrecision(18, 2);
        b.Property(x => x.Currency).HasColumnType("char(3)").HasMaxLength(3);
        b.Property(x => x.Status).HasConversion<int>();
        b.Property(x => x.ShippingAddressJson).HasColumnType("json");
        b.Property(x => x.CancelReason).HasColumnType("varchar(500)").HasMaxLength(500);
        b.Property(x => x.CancelledAtUtc).HasColumnType("datetime(6)"); b.Property(x => x.StockReturnedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => x.OrderNumber).IsUnique();
        b.HasIndex(x => new { x.CustomerAccountId, x.CreatedAtUtc });
        b.HasIndex(x => new { x.Status, x.CreatedAtUtc });
        b.HasOne(x => x.CustomerAccount).WithMany().HasForeignKey(x => x.CustomerAccountId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class OrderPackageConfiguration : IEntityTypeConfiguration<OrderPackage>
{
    public void Configure(EntityTypeBuilder<OrderPackage> b)
    {
        b.ToTable("order_packages"); b.ConfigureEntityBase();
        b.Property(x => x.OrderId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.SellerProfileId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.SellerStoreNameSnapshot).HasColumnType("varchar(160)").HasMaxLength(160);
        b.Property(x => x.Status).HasConversion<int>(); b.Property(x => x.Subtotal).HasPrecision(18, 2); b.Property(x => x.ShippingFee).HasPrecision(18, 2);
        b.Property(x => x.CancelledAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => new { x.SellerProfileId, x.Status, x.CreatedAtUtc });
        b.HasIndex(x => new { x.OrderId, x.Status });
        b.HasOne(x => x.Order).WithMany(x => x.Packages).HasForeignKey(x => x.OrderId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.SellerProfile).WithMany().HasForeignKey(x => x.SellerProfileId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class OrderItemConfiguration : IEntityTypeConfiguration<OrderItem>
{
    public void Configure(EntityTypeBuilder<OrderItem> b)
    {
        b.ToTable("order_items", t => t.HasCheckConstraint("ck_order_items_quantity", "quantity > 0")); b.ConfigureEntityBase();
        b.Property(x => x.OrderId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.OrderPackageId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.ProductId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.SellerProfileId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.ProductTitleSnapshot).HasColumnType("varchar(240)").HasMaxLength(240);
        b.Property(x => x.SellerNameSnapshot).HasColumnType("varchar(160)").HasMaxLength(160);
        b.Property(x => x.PhotoIdSnapshot).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.UnitPrice).HasPrecision(18, 2); b.Property(x => x.TotalPrice).HasPrecision(18, 2);
        b.HasIndex(x => x.OrderId); b.HasIndex(x => x.OrderPackageId); b.HasIndex(x => new { x.ProductId, x.OrderId });
        b.HasOne(x => x.Order).WithMany(x => x.Items).HasForeignKey(x => x.OrderId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.OrderPackage).WithMany(x => x.Items).HasForeignKey(x => x.OrderPackageId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.SellerProfile).WithMany().HasForeignKey(x => x.SellerProfileId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.PhotoSnapshot).WithMany().HasForeignKey(x => x.PhotoIdSnapshot).OnDelete(DeleteBehavior.SetNull);
    }
}

public sealed class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> b)
    {
        b.ToTable("payments"); b.ConfigureEntityBase();
        b.Property(x => x.CustomerAccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.OrderId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.Provider).HasColumnType("varchar(60)").HasMaxLength(60);
        b.Property(x => x.ProviderTransactionId).HasColumnType("varchar(120)").HasMaxLength(120);
        b.Property(x => x.Status).HasConversion<int>(); b.Property(x => x.Amount).HasPrecision(18, 2);
        b.Property(x => x.Currency).HasColumnType("char(3)").HasMaxLength(3);
        b.Property(x => x.CardBrand).HasColumnType("varchar(40)").HasMaxLength(40); b.Property(x => x.CardLast4).HasColumnType("char(4)").HasMaxLength(4);
        b.Property(x => x.FailureCode).HasColumnType("varchar(100)").HasMaxLength(100); b.Property(x => x.ProcessedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => new { x.Provider, x.ProviderTransactionId }).IsUnique(); b.HasIndex(x => x.OrderId);
        b.HasOne(x => x.CustomerAccount).WithMany().HasForeignKey(x => x.CustomerAccountId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.Order).WithMany(x => x.Payments).HasForeignKey(x => x.OrderId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class CheckoutRequestConfiguration : IEntityTypeConfiguration<CheckoutRequest>
{
    public void Configure(EntityTypeBuilder<CheckoutRequest> b)
    {
        b.ToTable("checkout_requests"); b.ConfigureEntityBase();
        b.Property(x => x.CustomerAccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.Endpoint).HasColumnType("varchar(100)").HasMaxLength(100);
        b.Property(x => x.IdempotencyKey).HasColumnType("varchar(100)").HasMaxLength(100).UseCollation("ascii_bin");
        b.Property(x => x.RequestHash).HasColumnType("char(64)").HasMaxLength(64);
        b.Property(x => x.Status).HasConversion<int>(); b.Property(x => x.OrderId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.ResponseJson).HasColumnType("json"); b.Property(x => x.FailureCode).HasColumnType("varchar(100)").HasMaxLength(100);
        b.Property(x => x.ExpiresAtUtc).HasColumnType("datetime(6)"); b.Property(x => x.CompletedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => new { x.CustomerAccountId, x.Endpoint, x.IdempotencyKey }).IsUnique(); b.HasIndex(x => x.ExpiresAtUtc);
        b.HasOne(x => x.CustomerAccount).WithMany().HasForeignKey(x => x.CustomerAccountId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.Order).WithMany().HasForeignKey(x => x.OrderId).OnDelete(DeleteBehavior.Restrict);
    }
}
