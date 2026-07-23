using ECommerce.Application.Common.Abstractions;
using ECommerce.Domain.Catalog;
using ECommerce.Domain.Fulfillment;
using ECommerce.Domain.Identity;
using ECommerce.Domain.Media;
using ECommerce.Domain.Operations;
using ECommerce.Domain.Orders;
using ECommerce.Domain.Profiles;
using ECommerce.Domain.Shopping;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Infrastructure.Persistence;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options), IAppDbContext
{
    public DbSet<Account> Accounts => Set<Account>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<RefreshSession> RefreshSessions => Set<RefreshSession>();
    public DbSet<AccessTokenRecord> AccessTokenRecords => Set<AccessTokenRecord>();
    public DbSet<SellerProfile> SellerProfiles => Set<SellerProfile>();
    public DbSet<Address> Addresses => Set<Address>();
    public DbSet<Photo> Photos => Set<Photo>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<ProductPhoto> ProductPhotos => Set<ProductPhoto>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<ReviewPhoto> ReviewPhotos => Set<ReviewPhoto>();
    public DbSet<Favorite> Favorites => Set<Favorite>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderPackage> OrderPackages => Set<OrderPackage>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<CheckoutRequest> CheckoutRequests => Set<CheckoutRequest>();
    public DbSet<ShippingCarrier> ShippingCarriers => Set<ShippingCarrier>();
    public DbSet<Shipment> Shipments => Set<Shipment>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
