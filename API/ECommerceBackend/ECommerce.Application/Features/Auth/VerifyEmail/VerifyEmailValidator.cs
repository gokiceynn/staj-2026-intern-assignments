using FluentValidation;
namespace ECommerce.Application.Features.Auth.VerifyEmail;
public sealed class VerifyEmailValidator : AbstractValidator<VerifyEmailCommand>
{
    public VerifyEmailValidator()
    {
        RuleFor(x => x.SessionId).NotEmpty().MaximumLength(80);
        RuleFor(x => x.Code).Matches("^[0-9]{6}$");
    }
}
