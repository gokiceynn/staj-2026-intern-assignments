namespace ECommerce.Application.Features.Accounts.StartEmailChange;
public sealed record StartEmailChangeCommand(string NewEmail, string Password);
public sealed record StartEmailChangeResult(string SessionId, DateTime ExpiresAtUtc);
