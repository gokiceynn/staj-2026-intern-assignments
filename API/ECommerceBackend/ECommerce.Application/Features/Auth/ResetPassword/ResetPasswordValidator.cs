using FluentValidation;
namespace ECommerce.Application.Features.Auth.ResetPassword;
public sealed class ResetPasswordValidator : AbstractValidator<ResetPasswordCommand>
{
    public ResetPasswordValidator()
    {
        RuleFor(x => x.SessionId).NotEmpty().MaximumLength(80);
        RuleFor(x => x.Code).Matches("^[0-9]{6}$");
        RuleFor(x => x.NewPassword).MinimumLength(12).MaximumLength(128).Matches("[A-Z]").Matches("[a-z]").Matches("[0-9]");
        RuleFor(x => x.NewPasswordConfirm).Equal(x => x.NewPassword);
    }
}
