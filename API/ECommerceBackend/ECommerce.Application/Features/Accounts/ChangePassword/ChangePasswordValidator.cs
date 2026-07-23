using FluentValidation;
namespace ECommerce.Application.Features.Accounts.ChangePassword;
public sealed class ChangePasswordValidator : AbstractValidator<ChangePasswordCommand>
{
    public ChangePasswordValidator()
    {
        RuleFor(x => x.CurrentPassword).NotEmpty().MaximumLength(128);
        RuleFor(x => x.NewPassword).MinimumLength(12).MaximumLength(128).Matches("[A-Z]").Matches("[a-z]").Matches("[0-9]");
        RuleFor(x => x.NewPasswordConfirm).Equal(x => x.NewPassword);
        RuleFor(x => x.NewPassword).NotEqual(x => x.CurrentPassword);
    }
}
