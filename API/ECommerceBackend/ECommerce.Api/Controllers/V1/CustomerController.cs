using ECommerce.Api.Contracts.V1;
using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.Addresses.CreateAddress;
using ECommerce.Application.Features.Addresses.DeleteAddress;
using ECommerce.Application.Features.Addresses.GetAddress;
using ECommerce.Application.Features.Addresses.ListAddresses;
using ECommerce.Application.Features.Addresses.UpdateAddress;
using ECommerce.Application.Features.Customers.DeleteMe;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace ECommerce.Api.Controllers.V1;
[ApiController, Authorize(Policy = PolicyNames.CustomerOnly), Route("api/v1/customer/me")]
public sealed class CustomerController(IClock clock) : ControllerBase
{
    [HttpDelete, RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Delete(DeleteCustomerRequest r, [FromServices] DeleteMeHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Password), ct)).ToActionResult(this, clock, "Hesabınız başarıyla silindi.");
    [HttpGet("addresses")]
    public async Task<IActionResult> Addresses([FromServices] ListAddressesHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Adres listesi getirildi.");
    [HttpGet("addresses/{id}")]
    public async Task<IActionResult> Address(string id, [FromServices] GetAddressHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Adres detayı getirildi.");
    [HttpPost("addresses"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> CreateAddress(AddressWriteRequest r, [FromServices] CreateAddressHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Title, r.AddressLine, r.City, r.District, r.ZipCode, r.PhoneNumber), ct))
            .ToActionResult(this, clock, "Adres başarıyla eklendi.", StatusCodes.Status201Created);
    [HttpPut("addresses/{id}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> UpdateAddress(string id, AddressWriteRequest r, [FromServices] UpdateAddressHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id, r.Title, r.AddressLine, r.City, r.District, r.ZipCode, r.PhoneNumber), ct))
            .ToActionResult(this, clock, "Adres başarıyla güncellendi.");
    [HttpDelete("addresses/{id}"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> DeleteAddress(string id, [FromServices] DeleteAddressHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(id), ct)).ToActionResult(this, clock, "Adres başarıyla silindi.");
}
