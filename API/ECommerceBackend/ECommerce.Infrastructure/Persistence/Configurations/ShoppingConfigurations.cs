using ECommerce.Domain.Shopping;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ECommerce.Infrastructure.Persistence.Configurations;

public sealed class FavoriteConfiguration : IEntityTypeConfiguration<Favorite>
{
    public void Configure(EntityTypeBuilder<Favorite> b)
    {
        b.ToTable("favorites"); b.HasKey(x => new { x.CustomerAccountId, x.ProductId });
        b.Property(x => x.CustomerAccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.ProductId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.AddedAtUtc).HasColumnType("datetime(6)");
        b.HasOne(x => x.CustomerAccount).WithMany().HasForeignKey(x => x.CustomerAccountId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class CartConfiguration : IEntityTypeConfiguration<Cart>
{
    public void Configure(EntityTypeBuilder<Cart> b)
    {
        b.ToTable("carts"); b.ConfigureEntityBase();
        b.Property(x => x.CustomerAccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.HasIndex(x => new { x.CustomerAccountId, x.IsActive }).IsUnique();
        b.HasOne(x => x.CustomerAccount).WithMany().HasForeignKey(x => x.CustomerAccountId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class CartItemConfiguration : IEntityTypeConfiguration<CartItem>
{
    public void Configure(EntityTypeBuilder<CartItem> b)
    {
        b.ToTable("cart_items", t => t.HasCheckConstraint("ck_cart_items_quantity", "quantity > 0"));
        b.HasKey(x => new { x.CartId, x.ProductId });
        b.Property(x => x.CartId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.ProductId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.AddedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.UpdatedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.Version).HasColumnType("bigint").IsConcurrencyToken();
        b.HasOne(x => x.Cart).WithMany(x => x.Items).HasForeignKey(x => x.CartId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Restrict);
    }
}
