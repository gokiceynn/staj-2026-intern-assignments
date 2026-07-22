using FluentValidation;
namespace ECommerce.Application.Features.Accounts.ResendEmailChange;
public sealed class ResendEmailChangeValidator : AbstractValidator<ResendEmailChangeCommand>
{
    public ResendEmailChangeValidator()
    {
        RuleFor(x => x.Password).NotEmpty().MaximumLength(128);
        RuleFor(x => x.SessionId).NotEmpty().MaximumLength(80);
    }
}
