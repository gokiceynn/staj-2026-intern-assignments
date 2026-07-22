namespace ECommerce.Api.Contracts.V1;
public sealed record RegisterCustomerRequest(string Email, string Password, string PasswordConfirm, string FirstName, string LastName, string PhoneNumber);
public sealed record RegisterSellerRequest(string Email, string Password, string PasswordConfirm, string FirstName, string LastName,
    string PhoneNumber, string StoreName, string TaxNumber, string TaxOffice);
public sealed record LoginRequest(string Email, string Password);
public sealed record RefreshTokenRequest(string RefreshToken);
public sealed record VerifyEmailRequest(string SessionId, string Code);
public sealed record ResendEmailRequest(string Email);
public sealed record ForgotPasswordRequest(string Email);
public sealed record ResetPasswordRequest(string SessionId, string Code, string NewPassword, string NewPasswordConfirm);
