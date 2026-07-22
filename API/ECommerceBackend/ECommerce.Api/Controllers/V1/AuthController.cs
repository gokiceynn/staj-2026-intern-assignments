using ECommerce.Api.Contracts.V1;
using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.Auth.ForgotPassword;
using ECommerce.Application.Features.Auth.Login;
using ECommerce.Application.Features.Auth.Logout;
using ECommerce.Application.Features.Auth.RefreshToken;
using ECommerce.Application.Features.Auth.RegisterCustomer;
using ECommerce.Application.Features.Auth.RegisterSeller;
using ECommerce.Application.Features.Auth.ResendEmailCode;
using ECommerce.Application.Features.Auth.ResetPassword;
using ECommerce.Application.Features.Auth.VerifyEmail;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace ECommerce.Api.Controllers.V1;
[ApiController, Route("api/v1/auth")]
public sealed class AuthController(IClock clock) : ControllerBase
{
    [AllowAnonymous, HttpPost("customer/register"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> RegisterCustomer(RegisterCustomerRequest r, [FromServices] RegisterCustomerHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Email, r.Password, r.PasswordConfirm, r.FirstName, r.LastName, r.PhoneNumber), ct))
            .ToActionResult(this, clock, "Kullanıcı kaydı alındı. E-posta adresinize gelen kodu giriniz.");

    [AllowAnonymous, HttpPost("seller/register"), RedisRateLimit(RateLimitPolicyNames.Mutation)]
    public async Task<IActionResult> RegisterSeller(RegisterSellerRequest r, [FromServices] RegisterSellerHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Email, r.Password, r.PasswordConfirm, r.FirstName, r.LastName, r.PhoneNumber, r.StoreName, r.TaxNumber, r.TaxOffice), ct))
            .ToActionResult(this, clock, "Satıcı kaydı alındı. E-posta adresinize gelen kodu giriniz.");

    [AllowAnonymous, HttpPost("login"), RedisRateLimit(RateLimitPolicyNames.Login)]
    public async Task<IActionResult> Login(LoginRequest r, [FromServices] LoginHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Email, r.Password), ct)).ToActionResult(this, clock, "Giriş başarılı.");

    [Authorize, HttpPost("logout")]
    public async Task<IActionResult> Logout([FromServices] LogoutHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Başarıyla çıkış yapıldı.");

    [AllowAnonymous, HttpPost("refresh-token"), RedisRateLimit(RateLimitPolicyNames.Refresh)]
    public async Task<IActionResult> Refresh(RefreshTokenRequest r, [FromServices] RefreshTokenHandler h, CancellationToken ct)
    {
        string header = Request.Headers.Authorization.ToString();
        string expired = header.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase) ? header[7..].Trim() : string.Empty;
        return (await h.HandleAsync(new(r.RefreshToken, expired), ct)).ToActionResult(this, clock, "Token başarıyla yenilendi.");
    }

    [AllowAnonymous, HttpPost("email/verify"), RedisRateLimit(RateLimitPolicyNames.OtpVerify)]
    public async Task<IActionResult> VerifyEmail(VerifyEmailRequest r, [FromServices] VerifyEmailHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.SessionId, r.Code), ct)).ToActionResult(this, clock, "Hesap doğrulandı ve oturum açıldı.");

    [AllowAnonymous, HttpPost("email/resend"), RedisRateLimit(RateLimitPolicyNames.OtpResend)]
    public async Task<IActionResult> Resend(ResendEmailRequest r, [FromServices] ResendEmailCodeHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Email), ct)).ToActionResult(this, clock, "Yeni doğrulama kodu gönderildi.");

    [AllowAnonymous, HttpPost("forgot-password"), RedisRateLimit(RateLimitPolicyNames.ForgotPassword)]
    public async Task<IActionResult> Forgot(ForgotPasswordRequest r, [FromServices] ForgotPasswordHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.Email), ct)).ToActionResult(this, clock, "Hesap mevcutsa sıfırlama kodu gönderildi.");

    [AllowAnonymous, HttpPost("reset-password"), RedisRateLimit(RateLimitPolicyNames.OtpVerify)]
    public async Task<IActionResult> Reset(ResetPasswordRequest r, [FromServices] ResetPasswordHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(r.SessionId, r.Code, r.NewPassword, r.NewPasswordConfirm), ct)).ToActionResult(this, clock, "Şifreniz başarıyla güncellendi.");
}
