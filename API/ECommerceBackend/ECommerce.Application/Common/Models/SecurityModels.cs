namespace ECommerce.Application.Common.Models;

public sealed record IssuedAccessToken(string Token, string Jti, DateTime IssuedAtUtc, DateTime ExpiresAtUtc);
public sealed record TokenPair(string AccessToken, DateTime AccessTokenExpiresAtUtc, string RefreshToken, DateTime RefreshTokenExpiresAtUtc);
public sealed record PaymentCardInput(string CardHolderName, string CardNumber, int ExpiryMonth, int ExpiryYear, string Cvv);
public sealed record PaymentGatewayResult(bool IsSuccess, string TransactionId, string? CardBrand, string? CardLast4, string? FailureCode);
