namespace ECommerce.Application.Features.Auth.ResetPassword;
public sealed record ResetPasswordCommand(string SessionId, string Code, string NewPassword, string NewPasswordConfirm);
