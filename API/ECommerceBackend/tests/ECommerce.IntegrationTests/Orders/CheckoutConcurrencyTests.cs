using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Domain.Catalog;
using ECommerce.Domain.Profiles;
using ECommerce.Domain.Shopping;
using ECommerce.Infrastructure.Persistence;
using ECommerce.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace ECommerce.IntegrationTests.Orders;
public sealed class CheckoutConcurrencyTests(ApiFactory factory) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task LastStockItem_CanBePurchasedByOnlyOneCustomer()
    {
        var first = await TestUserFactory.CreateAsync(factory); var second = await TestUserFactory.CreateAsync(factory);
        var seller = await TestUserFactory.CreateAsync(factory, "Seller");
        string productId = "prod_" + Guid.NewGuid().ToString("N"), firstAddress, secondAddress;
        using (IServiceScope seedScope = factory.Services.CreateScope())
        {
            AppDbContext db = seedScope.ServiceProvider.GetRequiredService<AppDbContext>();
            SellerProfile profile = new() { Id = "sel_" + Guid.NewGuid().ToString("N"), AccountId = seller.AccountId,
                StoreName = "Test Store", TaxNumber = "1234567890", TaxOffice = "Test", IsActive = true, CreatedAtUtc = factory.Clock.UtcNow };
            Category category = new() { Id = "cat_" + Guid.NewGuid().ToString("N"), Name = "Test", Slug = Guid.NewGuid().ToString("N"), IsActive = true, CreatedAtUtc = factory.Clock.UtcNow };
            db.AddRange(profile, category, new Product { Id = productId, SellerProfileId = profile.Id, CategoryId = category.Id,
                Title = "Last item", Description = "Concurrency product", Price = 100, Stock = 1, IsActive = true, CreatedAtUtc = factory.Clock.UtcNow });
            firstAddress = AddCartAndAddress(db, first.AccountId, productId); secondAddress = AddCartAndAddress(db, second.AccountId, productId);
            await db.SaveChangesAsync();
        }
        PaymentCardInput card = new("Test User", "4355123456789012", 12, 2030, "123");
        Task<Result<ECommerce.Application.Features.Orders.OrderDetailDto>> Run(string account, string address, string key) => Task.Run(async () =>
        {
            using IServiceScope scope = factory.Services.CreateScope();
            return await scope.ServiceProvider.GetRequiredService<IOrderService>().CheckoutAsync(account, address, card, key, default);
        });
        var results = await Task.WhenAll(Run(first.AccountId, firstAddress, Guid.NewGuid().ToString("N")),
            Run(second.AccountId, secondAddress, Guid.NewGuid().ToString("N")));
        Assert.Single(results.Where(x => x.IsSuccess));
        using IServiceScope assertScope = factory.Services.CreateScope();
        AppDbContext assertDb = assertScope.ServiceProvider.GetRequiredService<AppDbContext>();
        Assert.Equal(0, await assertDb.Products.Where(x => x.Id == productId).Select(x => x.Stock).SingleAsync());
        Assert.Equal(1, await assertDb.Orders.CountAsync(x => x.Items.Any(i => i.ProductId == productId)));
    }

    private static string AddCartAndAddress(AppDbContext db, string accountId, string productId)
    {
        string cartId = "crt_" + Guid.NewGuid().ToString("N"), addressId = "adr_" + Guid.NewGuid().ToString("N");
        db.Carts.Add(new Cart { Id = cartId, CustomerAccountId = accountId, IsActive = true, CreatedAtUtc = DateTime.UtcNow,
            Items = [new CartItem { CartId = cartId, ProductId = productId, Quantity = 1, AddedAtUtc = DateTime.UtcNow, Version = 1 }] });
        db.Addresses.Add(new Address { Id = addressId, AccountId = accountId, Title = "Home", AddressLine = "Street 1",
            City = "Istanbul", District = "Avcilar", ZipCode = "34320", PhoneNumber = "+905551112233", IsActive = true, CreatedAtUtc = DateTime.UtcNow });
        return addressId;
    }
}
