using ECommerce.Domain.Fulfillment;
using ECommerce.Domain.Operations;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
namespace ECommerce.Infrastructure.Persistence.Configurations;

public sealed class ShippingCarrierConfiguration : IEntityTypeConfiguration<ShippingCarrier>
{
    public void Configure(EntityTypeBuilder<ShippingCarrier> b)
    {
        b.ToTable("shipping_carriers"); b.ConfigureEntityBase();
        b.Property(x => x.Name).HasColumnType("varchar(160)").HasMaxLength(160); b.Property(x => x.Code).HasColumnType("varchar(40)").HasMaxLength(40).UseCollation("ascii_bin");
        b.Property(x => x.LogoPhotoId).HasColumnType("varchar(40)").HasMaxLength(40); b.Property(x => x.FlatFee).HasPrecision(18, 2);
        b.Property(x => x.TrackingUrlTemplate).HasColumnType("varchar(500)").HasMaxLength(500); b.Property(x => x.DeactivatedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => x.Code).IsUnique(); b.HasIndex(x => new { x.IsActive, x.Name });
        b.HasOne(x => x.LogoPhoto).WithMany().HasForeignKey(x => x.LogoPhotoId).OnDelete(DeleteBehavior.SetNull);
    }
}

public sealed class ShipmentConfiguration : IEntityTypeConfiguration<Shipment>
{
    public void Configure(EntityTypeBuilder<Shipment> b)
    {
        b.ToTable("shipments"); b.ConfigureEntityBase();
        b.Property(x => x.OrderPackageId).HasColumnType("varchar(40)").HasMaxLength(40); b.Property(x => x.ShippingCarrierId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.Status).HasConversion<int>(); b.Property(x => x.TrackingNumber).HasColumnType("varchar(120)").HasMaxLength(120);
        b.Property(x => x.TrackingUrl).HasColumnType("varchar(500)").HasMaxLength(500); b.Property(x => x.ShippedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.DeliveredAtUtc).HasColumnType("datetime(6)"); b.Property(x => x.CancelledAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => x.OrderPackageId).IsUnique(); b.HasIndex(x => new { x.ShippingCarrierId, x.TrackingNumber }).IsUnique();
        b.HasOne(x => x.OrderPackage).WithOne(x => x.Shipment).HasForeignKey<Shipment>(x => x.OrderPackageId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.ShippingCarrier).WithMany(x => x.Shipments).HasForeignKey(x => x.ShippingCarrierId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class OutboxMessageConfiguration : IEntityTypeConfiguration<OutboxMessage>
{
    public void Configure(EntityTypeBuilder<OutboxMessage> b)
    {
        b.ToTable("outbox_messages"); b.ConfigureEntityBase();
        b.Property(x => x.MessageType).HasColumnType("varchar(160)").HasMaxLength(160); b.Property(x => x.EncryptedPayload).HasColumnType("longtext");
        b.Property(x => x.Status).HasConversion<int>(); b.Property(x => x.NextAttemptAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.LockId).HasColumnType("varchar(64)").HasMaxLength(64); b.Property(x => x.LockedUntilUtc).HasColumnType("datetime(6)");
        b.Property(x => x.ProcessedAtUtc).HasColumnType("datetime(6)"); b.Property(x => x.LastError).HasColumnType("varchar(2000)").HasMaxLength(2000);
        b.HasIndex(x => new { x.Status, x.NextAttemptAtUtc, x.CreatedAtUtc }); b.HasIndex(x => x.LockedUntilUtc);
    }
}

public sealed class AuditLogConfiguration : IEntityTypeConfiguration<AuditLog>
{
    public void Configure(EntityTypeBuilder<AuditLog> b)
    {
        b.ToTable("audit_logs"); b.ConfigureEntityBase();
        b.Property(x => x.ActorAccountId).HasColumnType("varchar(40)").HasMaxLength(40); b.Property(x => x.Action).HasColumnType("varchar(160)").HasMaxLength(160);
        b.Property(x => x.EntityType).HasColumnType("varchar(120)").HasMaxLength(120); b.Property(x => x.EntityId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.CorrelationId).HasColumnType("varchar(100)").HasMaxLength(100); b.Property(x => x.IpAddress).HasColumnType("varchar(64)").HasMaxLength(64);
        b.Property(x => x.UserAgentHash).HasColumnType("char(64)").HasMaxLength(64); b.Property(x => x.MetadataJson).HasColumnType("json");
        b.HasIndex(x => new { x.ActorAccountId, x.CreatedAtUtc }); b.HasIndex(x => new { x.EntityType, x.EntityId, x.CreatedAtUtc });
    }
}
