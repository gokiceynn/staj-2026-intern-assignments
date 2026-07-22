using ECommerce.Domain.Media;
using ECommerce.Domain.Profiles;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ECommerce.Infrastructure.Persistence.Configurations;

public sealed class SellerProfileConfiguration : IEntityTypeConfiguration<SellerProfile>
{
    public void Configure(EntityTypeBuilder<SellerProfile> b)
    {
        b.ToTable("seller_profiles"); b.ConfigureEntityBase();
        b.Property(x => x.AccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.StoreName).HasColumnType("varchar(160)").HasMaxLength(160);
        b.Property(x => x.Description).HasColumnType("text");
        b.Property(x => x.TaxNumber).HasColumnType("varchar(20)").HasMaxLength(20);
        b.Property(x => x.TaxOffice).HasColumnType("varchar(120)").HasMaxLength(120);
        b.Property(x => x.LogoPhotoId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.RatingAverage).HasPrecision(3, 2);
        b.Property(x => x.DeactivatedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => x.AccountId).IsUnique();
        b.HasIndex(x => new { x.IsActive, x.StoreName });
        b.HasOne(x => x.Account).WithOne(x => x.SellerProfile).HasForeignKey<SellerProfile>(x => x.AccountId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.LogoPhoto).WithMany().HasForeignKey(x => x.LogoPhotoId).OnDelete(DeleteBehavior.SetNull);
    }
}

public sealed class AddressConfiguration : IEntityTypeConfiguration<Address>
{
    public void Configure(EntityTypeBuilder<Address> b)
    {
        b.ToTable("addresses"); b.ConfigureEntityBase();
        b.Property(x => x.AccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.Title).HasColumnType("varchar(80)").HasMaxLength(80);
        b.Property(x => x.AddressLine).HasColumnType("varchar(500)").HasMaxLength(500);
        b.Property(x => x.City).HasColumnType("varchar(100)").HasMaxLength(100);
        b.Property(x => x.District).HasColumnType("varchar(100)").HasMaxLength(100);
        b.Property(x => x.ZipCode).HasColumnType("varchar(20)").HasMaxLength(20);
        b.Property(x => x.PhoneNumber).HasColumnType("varchar(20)").HasMaxLength(20);
        b.Property(x => x.DeletedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => new { x.AccountId, x.IsActive });
        b.HasOne(x => x.Account).WithMany(x => x.Addresses).HasForeignKey(x => x.AccountId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class PhotoConfiguration : IEntityTypeConfiguration<Photo>
{
    public void Configure(EntityTypeBuilder<Photo> b)
    {
        b.ToTable("photos"); b.ConfigureEntityBase();
        b.Property(x => x.OwnerAccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.Purpose).HasConversion<int>();
        b.Property(x => x.StorageProvider).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.StorageKey).HasColumnType("varchar(500)").HasMaxLength(500);
        b.Property(x => x.OriginalFileName).HasColumnType("varchar(255)").HasMaxLength(255);
        b.Property(x => x.ContentType).HasColumnType("varchar(100)").HasMaxLength(100);
        b.Property(x => x.Sha256Hash).HasColumnType("char(64)").HasMaxLength(64);
        b.Property(x => x.LinkedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.DeletedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => x.StorageKey).IsUnique();
        b.HasIndex(x => new { x.OwnerAccountId, x.IsLinked, x.CreatedAtUtc });
        b.HasOne(x => x.OwnerAccount).WithMany().HasForeignKey(x => x.OwnerAccountId).OnDelete(DeleteBehavior.Restrict);
    }
}
