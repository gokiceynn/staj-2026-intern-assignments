using ECommerce.Api.Contracts.V1;
using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.AdminDashboard.GetAdminDashboard;
using ECommerce.Application.Features.AdminOrders.GetAdminOrder;
using ECommerce.Application.Features.AdminOrders.ListAdminOrders;
using ECommerce.Application.Features.AdminSellers.GetAdminSeller;
using ECommerce.Application.Features.AdminSellers.ListAdminSellers;
using ECommerce.Application.Features.AdminShippingCarriers.Create;
using ECommerce.Application.Features.AdminShippingCarriers.Delete;
using ECommerce.Application.Features.AdminShippingCarriers.Get;
using ECommerce.Application.Features.AdminShippingCarriers.List;
using ECommerce.Application.Features.AdminShippingCarriers.Update;
using ECommerce.Application.Features.AdminUsers.GetAdminUser;
using ECommerce.Application.Features.AdminUsers.ListAdminUsers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ECommerce.Api.Controllers.V1;

[ApiController, Authorize(Policy = PolicyNames.AdminOnly), Route("api/v1/admin")]
public sealed class AdminController(IClock clock) : ControllerBase
{
    [HttpGet("dashboard")]
    public async Task<IActionResult> Dashboard(
        DateTime? from,
        DateTime? to,
        [FromServices] GetAdminDashboardHandler h,
        CancellationToken ct
    ) =>
        (await h.HandleAsync(new(from, to), ct)).ToActionResult(
            this,
            clock,
            "Admin dashboard verileri getirildi."
        );

    [HttpGet("users")]
    public async Task<IActionResult> Users(
        int page,
        int size,
        string? q,
        string? role,
        bool? isActive,
        [FromServices] ListAdminUsersHandler h,
        CancellationToken ct
    ) =>
        (
            await h.HandleAsync(
                new(page == 0 ? 1 : page, size == 0 ? 20 : size, q, role, isActive),
                ct
            )
        ).ToActionResult(this, clock, "Kullanıcılar getirildi.");

    [HttpGet("users/{id}")]
    public async Task<IActionResult> User(
        string id,
        [FromServices] GetAdminUserHandler h,
        CancellationToken ct
    ) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(
            this,
            clock,
            "Kullanıcı detayı getirildi."
        );

    [HttpGet("sellers")]
    public async Task<IActionResult> Sellers(
        int page,
        int size,
        string? q,
        bool? isActive,
        [FromServices] ListAdminSellersHandler h,
        CancellationToken ct
    ) =>
        (
            await h.HandleAsync(new(page == 0 ? 1 : page, size == 0 ? 20 : size, q, isActive), ct)
        ).ToActionResult(this, clock, "Satıcılar getirildi.");

    [HttpGet("sellers/{id}")]
    public async Task<IActionResult> Seller(
        string id,
        [FromServices] GetAdminSellerHandler h,
        CancellationToken ct
    ) => (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Satıcı detayı getirildi.");

    [HttpGet("orders")]
    public async Task<IActionResult> Orders(
        int page,
        int size,
        string? status,
        DateTime? from,
        DateTime? to,
        [FromServices] ListAdminOrdersHandler h,
        CancellationToken ct
    ) =>
        (
            await h.HandleAsync(
                new(page == 0 ? 1 : page, size == 0 ? 20 : size, status, from, to),
                ct
            )
        ).ToActionResult(this, clock, "Siparişler getirildi.");

    [HttpGet("orders/{id}")]
    public async Task<IActionResult> Order(
        string id,
        [FromServices] GetAdminOrderHandler h,
        CancellationToken ct
    ) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Sipariş detayı getirildi.");

    [HttpGet("shipping-carriers")]
    public async Task<IActionResult> Carriers(
        [FromServices] ListAdminShippingCarriersHandler h,
        CancellationToken ct
    ) => (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Kargo firmaları getirildi.");

    [HttpGet("shipping-carriers/{id}")]
    public async Task<IActionResult> Carrier(
        string id,
        [FromServices] GetAdminShippingCarrierHandler h,
        CancellationToken ct
    ) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(
            this,
            clock,
            "Kargo firması detayı getirildi."
        );

    [HttpPost("shipping-carriers"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> CreateCarrier(
        ShippingCarrierWriteRequest r,
        [FromServices] CreateAdminShippingCarrierHandler h,
        CancellationToken ct
    ) =>
        (
            await h.HandleAsync(
                new(
                    r.Name,
                    r.Code,
                    r.LogoId,
                    r.FlatFee,
                    r.EstimatedDeliveryDays,
                    r.TrackingUrlTemplate,
                    r.IsActive
                ),
                ct
            )
        ).ToActionResult(this, clock, "Kargo firması eklendi.", 201);

    [HttpPut("shipping-carriers/{id}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> UpdateCarrier(
        string id,
        ShippingCarrierWriteRequest r,
        [FromServices] UpdateAdminShippingCarrierHandler h,
        CancellationToken ct
    ) =>
        (
            await h.HandleAsync(
                new(
                    id,
                    r.Name,
                    r.Code,
                    r.LogoId,
                    r.FlatFee,
                    r.EstimatedDeliveryDays,
                    r.TrackingUrlTemplate,
                    r.IsActive
                ),
                ct
            )
        ).ToActionResult(this, clock, "Kargo firması güncellendi.");

    [HttpDelete("shipping-carriers/{id}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> DeleteCarrier(
        string id,
        [FromServices] DeleteAdminShippingCarrierHandler h,
        CancellationToken ct
    ) => (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Kargo firması silindi.");
}

