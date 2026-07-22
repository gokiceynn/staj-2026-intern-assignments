namespace ECommerce.Application.Features.Auth.ResendEmailCode;
public sealed record ResendEmailCodeCommand(string Email);
public sealed record ResendEmailCodeResult(string SessionId, DateTime ExpiresAtUtc);
