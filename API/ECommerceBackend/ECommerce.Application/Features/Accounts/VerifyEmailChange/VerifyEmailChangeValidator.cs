using FluentValidation;
namespace ECommerce.Application.Features.Accounts.VerifyEmailChange;
public sealed class VerifyEmailChangeValidator : AbstractValidator<VerifyEmailChangeCommand>
{
    public VerifyEmailChangeValidator()
    {
        RuleFor(x => x.SessionId).NotEmpty().MaximumLength(80);
        RuleFor(x => x.Code).Matches("^[0-9]{6}$");
    }
}
