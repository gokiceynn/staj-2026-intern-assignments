using ECommerce.Api.Contracts.V1;
using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.Accounts.ChangePassword;
using ECommerce.Application.Features.Accounts.GetMe;
using ECommerce.Application.Features.Accounts.ResendEmailChange;
using ECommerce.Application.Features.Accounts.StartEmailChange;
using ECommerce.Application.Features.Accounts.UpdateMe;
using ECommerce.Application.Features.Accounts.VerifyEmailChange;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ECommerce.Api.Controllers.V1;

[ApiController, Authorize, Route("api/v1/account/me")]
public sealed class AccountController(IClock clock) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Get([FromServices] GetMeHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Hesap bilgileri getirildi.");

    [HttpPut, RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Update(
        UpdateAccountRequest r,
        [FromServices] UpdateMeHandler h,
        CancellationToken ct
    ) =>
        (await h.HandleAsync(new(r.FirstName, r.LastName, r.PhoneNumber), ct)).ToActionResult(
            this,
            clock,
            "Hesap bilgileri güncellendi."
        );

    [HttpPut("password"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> Password(
        ChangePasswordRequest r,
        [FromServices] ChangePasswordHandler h,
        CancellationToken ct
    ) =>
        (
            await h.HandleAsync(new(r.CurrentPassword, r.NewPassword, r.NewPasswordConfirm), ct)
        ).ToActionResult(this, clock, "Şifre başarıyla güncellendi.");

    [HttpPut("email"), RedisRateLimit(RateLimitPolicyNames.OtpResend)]
    public async Task<IActionResult> Email(
        StartEmailChangeRequest r,
        [FromServices] StartEmailChangeHandler h,
        CancellationToken ct
    ) =>
        (await h.HandleAsync(new(r.NewEmail, r.Password), ct)).ToActionResult(
            this,
            clock,
            "Yeni e-posta adresine doğrulama kodu gönderildi."
        );

    [HttpPost("email/verify"), RedisRateLimit(RateLimitPolicyNames.OtpVerify)]
    public async Task<IActionResult> VerifyEmail(
        VerifyEmailChangeRequest r,
        [FromServices] VerifyEmailChangeHandler h,
        CancellationToken ct
    ) =>
        (await h.HandleAsync(new(r.SessionId, r.Code), ct)).ToActionResult(
            this,
            clock,
            "E-posta adresi başarıyla güncellendi."
        );

    [HttpPost("email/resend"), RedisRateLimit(RateLimitPolicyNames.OtpResend)]
    public async Task<IActionResult> ResendEmail(
        ResendEmailChangeRequest r,
        [FromHeader(Name = "X-Otp-Session-Id")] string sessionId,
        [FromServices] ResendEmailChangeHandler h,
        CancellationToken ct
    ) =>
        (await h.HandleAsync(new(r.Password, sessionId), ct)).ToActionResult(
            this,
            clock,
            "Yeni doğrulama kodu gönderildi."
        );
}

