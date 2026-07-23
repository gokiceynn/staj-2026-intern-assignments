namespace ECommerce.Application.Features.Accounts.ChangePassword;
public sealed record ChangePasswordCommand(string CurrentPassword, string NewPassword, string NewPasswordConfirm);
