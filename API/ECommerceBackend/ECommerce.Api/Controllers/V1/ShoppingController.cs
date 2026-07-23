using ECommerce.Api.Contracts.V1;
using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.Cart.AddCartItem;
using ECommerce.Application.Features.Cart.ClearCart;
using ECommerce.Application.Features.Cart.GetCart;
using ECommerce.Application.Features.Cart.RemoveCartItem;
using ECommerce.Application.Features.Cart.UpdateCartItem;
using ECommerce.Application.Features.Favorites.AddFavorite;
using ECommerce.Application.Features.Favorites.ListFavorites;
using ECommerce.Application.Features.Favorites.RemoveFavorite;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace ECommerce.Api.Controllers.V1;
[ApiController, Authorize(Policy = PolicyNames.CustomerOnly), Route("api/v1")]
public sealed class ShoppingController(IClock clock) : ControllerBase
{
    [HttpGet("favorites")]
    public async Task<IActionResult> Favorites(int page, int size, [FromServices] ListFavoritesHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(page == 0 ? 1 : page, size == 0 ? 20 : size), ct)).ToActionResult(this, clock, "Favoriler getirildi.");
    [HttpPost("favorites/{productId}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> AddFavorite(string productId, [FromServices] AddFavoriteHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(productId), ct)).ToActionResult(this, clock, "Ürün favorilere eklendi.");
    [HttpDelete("favorites/{productId}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> RemoveFavorite(string productId, [FromServices] RemoveFavoriteHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(productId), ct)).ToActionResult(this, clock, "Ürün favorilerden kaldırıldı.");
    [HttpGet("cart")]
    public async Task<IActionResult> Cart([FromServices] GetCartHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Sepet getirildi.");
    [HttpPost("cart/items"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> AddCart(CartItemRequest r, [FromServices] AddCartItemHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.ProductId, r.Quantity), ct)).ToActionResult(this, clock, "Ürün sepete eklendi.");
    [HttpPut("cart/items/{productId}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> UpdateCart(string productId, UpdateCartItemRequest r, [FromServices] UpdateCartItemHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(productId, r.Quantity), ct)).ToActionResult(this, clock, "Sepet güncellendi.");
    [HttpDelete("cart/items/{productId}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> RemoveCart(string productId, [FromServices] RemoveCartItemHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(productId), ct)).ToActionResult(this, clock, "Ürün sepetten çıkarıldı.");
    [HttpDelete("cart"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Clear([FromServices] ClearCartHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Sepet temizlendi.");
}
