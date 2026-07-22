using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Features.Auth.RegisterCustomer;

public sealed record RegisterCustomerCommand(
    string Email,
    string Password,
    string PasswordConfirm,
    string FirstName,
    string LastName,
    string PhoneNumber);

public sealed record RegisterCustomerResult(string SessionId, DateTime ExpiresAtUtc);
