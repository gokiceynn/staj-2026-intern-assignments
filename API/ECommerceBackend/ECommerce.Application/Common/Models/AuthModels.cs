namespace ECommerce.Application.Common.Models;

public sealed record AccountSummary(
    string Id,
    string Email,
    string FirstName,
    string LastName,
    string PhoneNumber,
    string Role,
    DateTime CreatedAtUtc);

public sealed record AuthenticatedAccount(TokenPair Tokens, AccountSummary Account);
public sealed record OtpStartResult(string SessionId, DateTime ExpiresAtUtc);
