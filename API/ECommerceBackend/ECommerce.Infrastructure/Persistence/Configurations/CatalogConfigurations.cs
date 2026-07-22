using ECommerce.Domain.Catalog;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ECommerce.Infrastructure.Persistence.Configurations;

public sealed class CategoryConfiguration : IEntityTypeConfiguration<Category>
{
    public void Configure(EntityTypeBuilder<Category> b)
    {
        b.ToTable("categories"); b.ConfigureEntityBase();
        b.Property(x => x.Name).HasColumnType("varchar(160)").HasMaxLength(160);
        b.Property(x => x.Slug).HasColumnType("varchar(180)").HasMaxLength(180).UseCollation("ascii_bin");
        b.Property(x => x.ParentCategoryId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.IconPhotoId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.HasIndex(x => x.Slug).IsUnique();
        b.HasIndex(x => new { x.ParentCategoryId, x.IsActive, x.SortOrder });
        b.HasOne(x => x.ParentCategory).WithMany(x => x.Children).HasForeignKey(x => x.ParentCategoryId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.IconPhoto).WithMany().HasForeignKey(x => x.IconPhotoId).OnDelete(DeleteBehavior.SetNull);
    }
}

public sealed class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> b)
    {
        b.ToTable("products", t =>
        {
            t.HasCheckConstraint("ck_products_price", "`Price` > 0");
            t.HasCheckConstraint("ck_products_stock", "`Stock` >= 0");
            t.HasCheckConstraint("ck_products_rating", "`RatingAverage` >= 0 AND `RatingAverage` <= 5");
        });
        b.ConfigureEntityBase();
        b.Property(x => x.SellerProfileId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.CategoryId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.Title).HasColumnType("varchar(240)").HasMaxLength(240);
        b.Property(x => x.Description).HasColumnType("text");
        b.Property(x => x.Price).HasPrecision(18, 2);
        b.Property(x => x.RatingAverage).HasPrecision(3, 2);
        b.Property(x => x.FeaturesJson).HasColumnType("json");
        b.Property(x => x.DeactivatedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => new { x.IsActive, x.CategoryId, x.CreatedAtUtc });
        b.HasIndex(x => new { x.SellerProfileId, x.IsActive, x.CreatedAtUtc });
        b.HasIndex(x => new { x.IsActive, x.Price });
        b.HasOne(x => x.SellerProfile).WithMany(x => x.Products).HasForeignKey(x => x.SellerProfileId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.Category).WithMany(x => x.Products).HasForeignKey(x => x.CategoryId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class ProductPhotoConfiguration : IEntityTypeConfiguration<ProductPhoto>
{
    public void Configure(EntityTypeBuilder<ProductPhoto> b)
    {
        b.ToTable("product_photos");
        b.HasKey(x => new { x.ProductId, x.PhotoId });
        b.Property(x => x.ProductId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.PhotoId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.CreatedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => new { x.ProductId, x.DisplayOrder }).IsUnique();
        b.HasOne(x => x.Product).WithMany(x => x.Photos).HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(x => x.Photo).WithMany().HasForeignKey(x => x.PhotoId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> b)
    {
        b.ToTable("reviews", t => t.HasCheckConstraint("ck_reviews_rating", "rating BETWEEN 1 AND 5"));
        b.ConfigureEntityBase();
        b.Property(x => x.ProductId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.CustomerAccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.Comment).HasColumnType("varchar(1000)").HasMaxLength(1000);
        b.Property(x => x.DeletedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => new { x.CustomerAccountId, x.ProductId }).IsUnique();
        b.HasIndex(x => new { x.ProductId, x.IsActive, x.CreatedAtUtc });
        b.HasOne(x => x.Product).WithMany(x => x.Reviews).HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.CustomerAccount).WithMany().HasForeignKey(x => x.CustomerAccountId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class ReviewPhotoConfiguration : IEntityTypeConfiguration<ReviewPhoto>
{
    public void Configure(EntityTypeBuilder<ReviewPhoto> b)
    {
        b.ToTable("review_photos"); b.HasKey(x => new { x.ReviewId, x.PhotoId });
        b.Property(x => x.ReviewId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.PhotoId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.CreatedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => new { x.ReviewId, x.DisplayOrder }).IsUnique();
        b.HasOne(x => x.Review).WithMany(x => x.Photos).HasForeignKey(x => x.ReviewId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(x => x.Photo).WithMany().HasForeignKey(x => x.PhotoId).OnDelete(DeleteBehavior.Restrict);
    }
}
