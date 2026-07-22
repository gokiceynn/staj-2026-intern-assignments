using ECommerce.Api.Contracts.V1;
using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.SellerOrders.DeliverPackage;
using ECommerce.Application.Features.SellerOrders.GetSellerOrder;
using ECommerce.Application.Features.SellerOrders.ListSellerOrders;
using ECommerce.Application.Features.SellerOrders.PreparePackage;
using ECommerce.Application.Features.SellerOrders.ShipPackage;
using ECommerce.Application.Features.SellerProducts.CreateSellerProduct;
using ECommerce.Application.Features.SellerProducts.DeleteSellerProduct;
using ECommerce.Application.Features.SellerProducts.GetSellerProduct;
using ECommerce.Application.Features.SellerProducts.ListSellerProducts;
using ECommerce.Application.Features.SellerProducts.UpdateSellerProduct;
using ECommerce.Application.Features.SellerProfile.GetSellerDashboard;
using ECommerce.Application.Features.SellerProfile.GetSellerProfile;
using ECommerce.Application.Features.SellerProfile.UpdateSellerProfile;
using ECommerce.Application.Features.SellerShippingCarriers.ListSellerShippingCarriers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace ECommerce.Api.Controllers.V1;
[ApiController, Authorize(Policy = PolicyNames.SellerOnly), Route("api/v1/seller")]
public sealed class SellerController(IClock clock) : ControllerBase
{
    [HttpGet("profile")]
    public async Task<IActionResult> Profile([FromServices] GetSellerProfileHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Mağaza profili getirildi.");
    [HttpPut("profile"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> UpdateProfile(UpdateSellerProfileRequest r, [FromServices] UpdateSellerProfileHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.StoreName, r.Description, r.LogoId, r.TaxOffice), ct)).ToActionResult(this, clock, "Mağaza profili güncellendi.");
    [HttpGet("dashboard")]
    public async Task<IActionResult> Dashboard(DateTime? from, DateTime? to, [FromServices] GetSellerDashboardHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(from, to), ct)).ToActionResult(this, clock, "Satıcı dashboard verileri getirildi.");
    [HttpGet("products")]
    public async Task<IActionResult> Products(int page, int size, string? q, bool? isActive, [FromServices] ListSellerProductsHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(page == 0 ? 1 : page, size == 0 ? 10 : size, q, isActive), ct)).ToActionResult(this, clock, "Satıcı ürünleri getirildi.");
    [HttpGet("products/{id}")]
    public async Task<IActionResult> Product(string id, [FromServices] GetSellerProductHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Satıcı ürün detayı getirildi.");
    [HttpPost("products"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> CreateProduct(SellerProductWriteRequest r, [FromServices] CreateSellerProductHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Title, r.Description, r.Price, r.Stock, r.CategoryId, r.PhotoIds, r.Features, r.IsActive), ct))
            .ToActionResult(this, clock, "Ürün başarıyla eklendi.", 201);
    [HttpPut("products/{id}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> UpdateProduct(string id, SellerProductWriteRequest r, [FromServices] UpdateSellerProductHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id, r.Title, r.Description, r.Price, r.Stock, r.CategoryId, r.PhotoIds, r.Features, r.IsActive), ct))
            .ToActionResult(this, clock, "Ürün başarıyla güncellendi.");
    [HttpDelete("products/{id}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> DeleteProduct(string id, [FromServices] DeleteSellerProductHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Ürün satıştan kaldırıldı.");
    [HttpGet("shipping-carriers")]
    public async Task<IActionResult> Carriers([FromServices] ListSellerShippingCarriersHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Aktif kargo firmaları listelendi.");
    [HttpGet("orders")]
    public async Task<IActionResult> Orders(int page, int size, string? status, DateTime? from, DateTime? to,
        [FromServices] ListSellerOrdersHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(page == 0 ? 1 : page, size == 0 ? 10 : size, status, from, to), ct)).ToActionResult(this, clock, "Satıcı sipariş paketleri getirildi.");
    [HttpGet("orders/{packageId}")]
    public async Task<IActionResult> Order(string packageId, [FromServices] GetSellerOrderHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(packageId), ct)).ToActionResult(this, clock, "Sipariş paketi detayı getirildi.");
    [HttpPost("orders/{packageId}/prepare"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Prepare(string packageId, [FromServices] PreparePackageHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(packageId), ct)).ToActionResult(this, clock, "Paket hazırlanıyor.");
    [HttpPost("orders/{packageId}/ship"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Ship(string packageId, ShipPackageRequest r, [FromServices] ShipPackageHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(packageId, r.CarrierId, r.TrackingNumber), ct)).ToActionResult(this, clock, "Paket kargoya verildi.");
    [HttpPost("orders/{packageId}/deliver"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Deliver(string packageId, [FromServices] DeliverPackageHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(packageId), ct)).ToActionResult(this, clock, "Paket teslim edildi olarak işaretlendi.");
}
