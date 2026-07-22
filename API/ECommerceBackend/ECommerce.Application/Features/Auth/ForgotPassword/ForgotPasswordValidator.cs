using FluentValidation;
namespace ECommerce.Application.Features.Auth.ForgotPassword;
public sealed class ForgotPasswordValidator : AbstractValidator<ForgotPasswordCommand>
{
    public ForgotPasswordValidator() => RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(254);
}
