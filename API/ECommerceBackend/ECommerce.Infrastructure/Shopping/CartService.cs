using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Cart;
using ECommerce.Domain.Shopping;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Infrastructure.Shopping;
public sealed class CartService(AppDbContext db, ITransactionRunner transactions, IIdGenerator ids, IClock clock) : ICartService
{
    public async Task<Result<CartDto>> GetAsync(string accountId, CancellationToken ct)
    {
        Cart? cart = await db.Carts.AsNoTracking().Include(x => x.Items).ThenInclude(x => x.Product).ThenInclude(x => x.SellerProfile)
            .Include(x => x.Items).ThenInclude(x => x.Product).ThenInclude(x => x.Photos)
            .SingleOrDefaultAsync(x => x.CustomerAccountId == accountId && x.IsActive, ct);
        return Result<CartDto>.Success(Map(cart));
    }

    public Task<Result<CartDto>> AddAsync(string accountId, string productId, int quantity, CancellationToken ct) =>
        MutateAsync(accountId, productId, async (cart, token) =>
        {
            var product = await db.Products.SingleOrDefaultAsync(x => x.Id == productId && x.IsActive && x.SellerProfile.IsActive, token);
            if (product is null) return CommonErrors.NotFound;
            CartItem? item = cart.Items.SingleOrDefault(x => x.ProductId == productId);
            int next = (item?.Quantity ?? 0) + quantity;
            if (next > product.Stock) return new Error("INSUFFICIENT_STOCK", "Requested quantity exceeds available stock.");
            if (item is null) cart.Items.Add(new CartItem { CartId = cart.Id, ProductId = productId, Quantity = next, AddedAtUtc = clock.UtcNow, Version = 1 });
            else { item.Quantity = next; item.UpdatedAtUtc = clock.UtcNow; item.Version++; }
            return null;
        }, ct);

    public Task<Result<CartDto>> UpdateAsync(string accountId, string productId, int quantity, CancellationToken ct) =>
        MutateAsync(accountId, productId, async (cart, token) =>
        {
            CartItem? item = cart.Items.SingleOrDefault(x => x.ProductId == productId);
            if (item is null) return CommonErrors.NotFound;
            int stock = await db.Products.Where(x => x.Id == productId && x.IsActive).Select(x => x.Stock).SingleOrDefaultAsync(token);
            if (quantity > stock) return new Error("INSUFFICIENT_STOCK", "Requested quantity exceeds available stock.");
            item.Quantity = quantity; item.UpdatedAtUtc = clock.UtcNow; item.Version++; return null;
        }, ct);

    public Task<Result<CartDto>> RemoveAsync(string accountId, string productId, CancellationToken ct) =>
        MutateAsync(accountId, productId, (cart, token) =>
        { CartItem? item = cart.Items.SingleOrDefault(x => x.ProductId == productId); if (item is not null) db.CartItems.Remove(item); return Task.FromResult<Error?>(null); }, ct);

    public async Task<Result> ClearAsync(string accountId, CancellationToken ct)
    {
        await db.CartItems.Where(x => x.Cart.CustomerAccountId == accountId && x.Cart.IsActive).ExecuteDeleteAsync(ct);
        return Result.Success();
    }

    private Task<Result<CartDto>> MutateAsync(string accountId, string productId,
        Func<Cart, CancellationToken, Task<Error?>> mutation, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            Cart? cart = await db.Carts.Include(x => x.Items)
                .SingleOrDefaultAsync(x => x.CustomerAccountId == accountId && x.IsActive, token);
            if (cart is null)
            {
                cart = new Cart { Id = ids.NewId("crt"), CustomerAccountId = accountId, IsActive = true, CreatedAtUtc = clock.UtcNow };
                db.Carts.Add(cart);
            }
            Error? error = await mutation(cart, token);
            if (error is not null) return Result<CartDto>.Failure(error);
            await db.SaveChangesAsync(token);
            return await GetAsync(accountId, token);
        }, System.Data.IsolationLevel.ReadCommitted, ct);

    private static CartDto Map(Cart? cart)
    {
        if (cart is null) return new(string.Empty, [], 0, 0);
        var items = cart.Items.Select(x => new CartItemDto(x.ProductId, x.Quantity, x.Quantity * x.Product.Price,
            new CartProductDto(x.Product.Id, x.Product.Title, x.Product.Price, x.Product.Stock,
                x.Product.Photos.OrderBy(p => p.DisplayOrder).Select(p => p.PhotoId).FirstOrDefault(),
                x.Product.SellerProfileId, x.Product.SellerProfile.StoreName))).ToList();
        return new(cart.Id, items, items.Sum(x => x.LineTotal), items.Sum(x => x.Quantity));
    }
}
