namespace ECommerce.Application.Features.Auth.ForgotPassword;
public sealed record ForgotPasswordCommand(string Email);
public sealed record ForgotPasswordResult(string SessionId, DateTime ExpiresAtUtc);
