using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Common.Errors;

public static class AuthErrors
{
    public static readonly Error InvalidCredentials = new("INVALID_CREDENTIALS", "Email or password is incorrect.");
    public static readonly Error EmailAlreadyExists = new("EMAIL_ALREADY_EXISTS", "An account with this email already exists.");
    public static readonly Error EmailNotVerified = new("EMAIL_NOT_VERIFIED", "Email verification is required.");
    public static readonly Error AccountLocked = new("ACCOUNT_LOCKED", "The account is temporarily locked.");
    public static readonly Error InvalidOtp = new("INVALID_OTP", "The verification code is invalid or expired.");
    public static readonly Error InvalidRefreshToken = new("INVALID_REFRESH_TOKEN", "The refresh token is invalid.");
    public static readonly Error RefreshTokenReuse = new("REFRESH_TOKEN_REUSE", "Refresh token reuse was detected; all sessions were revoked.");
    public static readonly Error OtpCooldown = new("OTP_COOLDOWN", "A new code cannot be requested yet.");
    public static readonly Error RateLimited = new("RATE_LIMITED", "Too many authentication attempts.");
}
