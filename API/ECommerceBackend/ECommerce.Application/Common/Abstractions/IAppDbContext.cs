using ECommerce.Domain.Catalog;
using ECommerce.Domain.Fulfillment;
using ECommerce.Domain.Identity;
using ECommerce.Domain.Media;
using ECommerce.Domain.Operations;
using ECommerce.Domain.Orders;
using ECommerce.Domain.Profiles;
using ECommerce.Domain.Shopping;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;

namespace ECommerce.Application.Common.Abstractions;

public interface IAppDbContext
{
    DbSet<Account> Accounts { get; }
    DbSet<Role> Roles { get; }
    DbSet<RefreshSession> RefreshSessions { get; }
    DbSet<AccessTokenRecord> AccessTokenRecords { get; }
    DbSet<SellerProfile> SellerProfiles { get; }
    DbSet<Address> Addresses { get; }
    DbSet<Photo> Photos { get; }
    DbSet<Category> Categories { get; }
    DbSet<Product> Products { get; }
    DbSet<ProductPhoto> ProductPhotos { get; }
    DbSet<Review> Reviews { get; }
    DbSet<ReviewPhoto> ReviewPhotos { get; }
    DbSet<Favorite> Favorites { get; }
    DbSet<Cart> Carts { get; }
    DbSet<CartItem> CartItems { get; }
    DbSet<Order> Orders { get; }
    DbSet<OrderPackage> OrderPackages { get; }
    DbSet<OrderItem> OrderItems { get; }
    DbSet<Payment> Payments { get; }
    DbSet<CheckoutRequest> CheckoutRequests { get; }
    DbSet<ShippingCarrier> ShippingCarriers { get; }
    DbSet<Shipment> Shipments { get; }
    DbSet<OutboxMessage> OutboxMessages { get; }
    DbSet<AuditLog> AuditLogs { get; }
    DatabaseFacade Database { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
