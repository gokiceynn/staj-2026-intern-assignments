using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Auth.VerifyEmail;
public sealed record VerifyEmailCommand(string SessionId, string Code);
public sealed record VerifyEmailResult(string AccessToken, DateTime AccessTokenExpiresAtUtc,
    string RefreshToken, DateTime RefreshTokenExpiresAtUtc, AccountSummary Account);
