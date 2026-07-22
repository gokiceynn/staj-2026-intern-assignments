using FluentValidation;
namespace ECommerce.Application.Features.Accounts.StartEmailChange;
public sealed class StartEmailChangeValidator : AbstractValidator<StartEmailChangeCommand>
{
    public StartEmailChangeValidator()
    {
        RuleFor(x => x.NewEmail).NotEmpty().EmailAddress().MaximumLength(254);
        RuleFor(x => x.Password).NotEmpty().MaximumLength(128);
    }
}
