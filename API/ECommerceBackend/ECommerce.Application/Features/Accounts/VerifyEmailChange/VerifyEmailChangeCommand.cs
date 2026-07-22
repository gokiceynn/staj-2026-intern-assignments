namespace ECommerce.Application.Features.Accounts.VerifyEmailChange;
public sealed record VerifyEmailChangeCommand(string SessionId, string Code);
