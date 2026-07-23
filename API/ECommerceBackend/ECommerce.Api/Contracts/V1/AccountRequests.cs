namespace ECommerce.Api.Contracts.V1;

public sealed record UpdateAccountRequest(string FirstName, string LastName, string PhoneNumber);

public sealed record ChangePasswordRequest(
    string CurrentPassword,
    string NewPassword,
    string NewPasswordConfirm
);

public sealed record StartEmailChangeRequest(string NewEmail, string Password);

public sealed record VerifyEmailChangeRequest(string SessionId, string Code);

public sealed record ResendEmailChangeRequest(string Password);

public sealed record DeleteCustomerRequest(string Password);

