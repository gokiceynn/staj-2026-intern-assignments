using ECommerce.Api.Contracts.V1;
using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.Catalog.GetCategories;
using ECommerce.Application.Features.Catalog.GetProduct;
using ECommerce.Application.Features.Catalog.ListProducts;
using ECommerce.Application.Features.Reviews.CreateReview;
using ECommerce.Application.Features.Reviews.DeleteReview;
using ECommerce.Application.Features.Reviews.ListReviews;
using ECommerce.Application.Features.Reviews.UpdateReview;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace ECommerce.Api.Controllers.V1;
[ApiController, Route("api/v1")]
public sealed class CatalogController(IClock clock) : ControllerBase
{
    [AllowAnonymous, HttpGet("categories")]
    public async Task<IActionResult> Categories([FromServices] GetCategoriesHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Kategoriler listelendi.");
    [AllowAnonymous, HttpGet("products")]
    public async Task<IActionResult> Products([FromQuery] ListProductsQuery q, [FromServices] ListProductsHandler h, CancellationToken ct) =>
        (await h.HandleAsync(q, ct)).ToActionResult(this, clock, "Ürünler listelendi.");
    [AllowAnonymous, HttpGet("products/{id}")]
    public async Task<IActionResult> Product(string id, [FromServices] GetProductHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Ürün detayı getirildi.");
    [AllowAnonymous, HttpGet("products/{id}/reviews")]
    public async Task<IActionResult> Reviews(string id, int page, int size, string sortBy, [FromServices] ListReviewsHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id, page == 0 ? 1 : page, size == 0 ? 10 : size, string.IsNullOrWhiteSpace(sortBy) ? "newest" : sortBy), ct))
            .ToActionResult(this, clock, "Ürün yorumları getirildi.");
    [Authorize(Policy = PolicyNames.CustomerOnly), HttpPost("products/{id}/reviews"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> CreateReview(string id, ReviewWriteRequest r, [FromServices] CreateReviewHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id, r.Rating, r.Comment, r.PhotoIds), ct)).ToActionResult(this, clock, "Yorum başarıyla eklendi.", 201);
    [Authorize(Policy = PolicyNames.CustomerOnly), HttpPut("products/{productId}/reviews/{reviewId}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> UpdateReview(string productId, string reviewId, ReviewWriteRequest r, [FromServices] UpdateReviewHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(productId, reviewId, r.Rating, r.Comment, r.PhotoIds), ct)).ToActionResult(this, clock, "Yorum başarıyla güncellendi.");
    [Authorize(Policy = PolicyNames.CustomerOnly), HttpDelete("products/{productId}/reviews/{reviewId}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> DeleteReview(string productId, string reviewId, [FromServices] DeleteReviewHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(productId, reviewId), ct)).ToActionResult(this, clock, "Yorum başarıyla silindi.");
}
