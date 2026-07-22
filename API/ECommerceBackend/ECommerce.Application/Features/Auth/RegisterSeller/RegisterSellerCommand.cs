using ECommerce.Application.Features.Auth.RegisterCustomer;

namespace ECommerce.Application.Features.Auth.RegisterSeller;

public sealed record RegisterSellerCommand(
    string Email,
    string Password,
    string PasswordConfirm,
    string FirstName,
    string LastName,
    string PhoneNumber,
    string StoreName,
    string TaxNumber,
    string TaxOffice);

public sealed record RegisterSellerResult(string SessionId, DateTime ExpiresAtUtc);
