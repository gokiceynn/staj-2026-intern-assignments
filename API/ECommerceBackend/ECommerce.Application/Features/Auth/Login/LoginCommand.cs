using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Auth.Login;
public sealed record LoginCommand(string Email, string Password);
public sealed record LoginResult(string AccessToken, DateTime AccessTokenExpiresAtUtc,
    string RefreshToken, DateTime RefreshTokenExpiresAtUtc, AccountSummary Account);
