using ECommerce.Api.Contracts.V1;
using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.Orders.CancelOrder;
using ECommerce.Application.Features.Orders.Checkout;
using ECommerce.Application.Features.Orders.GetMyOrder;
using ECommerce.Application.Features.Orders.ListMyOrders;
using ECommerce.Application.Features.Payments.SimulatePayment;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace ECommerce.Api.Controllers.V1;
[ApiController, Authorize(Policy = PolicyNames.CustomerOnly), Route("api/v1")]
public sealed class OrdersController(IClock clock) : ControllerBase
{
    [HttpPost("payments/simulate"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Simulate(SimulatePaymentRequest r, [FromServices] SimulatePaymentHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Amount, r.PaymentCard.ToApplication()), ct)).ToActionResult(this, clock, "Ödeme simülasyonu başarıyla tamamlandı.");
    [HttpPost("orders/checkout"), RedisRateLimit(RateLimitPolicyNames.Checkout)]
    public async Task<IActionResult> Checkout(CheckoutRequest r, [FromHeader(Name = "Idempotency-Key")] string key,
        [FromServices] CheckoutHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.AddressId, r.PaymentCard.ToApplication(), key), ct)).ToActionResult(this, clock, "Sipariş alındı ve ödeme onaylandı.");
    [HttpGet("orders")]
    public async Task<IActionResult> List(int page, int size, string? status, [FromServices] ListMyOrdersHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(page == 0 ? 1 : page, size == 0 ? 10 : size, status), ct)).ToActionResult(this, clock, "Siparişler getirildi.");
    [HttpGet("orders/{id}")]
    public async Task<IActionResult> Get(string id, [FromServices] GetMyOrderHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Sipariş detayı getirildi.");
    [HttpPost("orders/{id}/cancel"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Cancel(string id, CancelOrderRequest r, [FromServices] CancelOrderHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id, r.CancelReason), ct)).ToActionResult(this, clock, "Sipariş başarıyla iptal edildi.");
}
