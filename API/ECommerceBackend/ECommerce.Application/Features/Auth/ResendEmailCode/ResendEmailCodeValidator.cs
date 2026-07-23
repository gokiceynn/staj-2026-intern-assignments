using FluentValidation;
namespace ECommerce.Application.Features.Auth.ResendEmailCode;
public sealed class ResendEmailCodeValidator : AbstractValidator<ResendEmailCodeCommand>
{
    public ResendEmailCodeValidator() => RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(254);
}
