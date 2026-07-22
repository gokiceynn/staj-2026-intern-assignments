using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Auth.RefreshToken;
public sealed record RefreshTokenCommand(string RefreshToken, string ExpiredAccessToken);
public sealed record RefreshTokenResult(string AccessToken, DateTime AccessTokenExpiresAtUtc,
    string RefreshToken, DateTime RefreshTokenExpiresAtUtc);
