namespace ECommerce.Application.Features.Accounts.ResendEmailChange;
public sealed record ResendEmailChangeCommand(string Password, string SessionId);
public sealed record ResendEmailChangeResult(string SessionId, DateTime ExpiresAtUtc);
