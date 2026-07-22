using FluentValidation;

namespace ECommerce.Application.Features.Auth.RegisterCustomer;

public sealed class RegisterCustomerValidator : AbstractValidator<RegisterCustomerCommand>
{
    public RegisterCustomerValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(254);
        RuleFor(x => x.Password).MinimumLength(12).MaximumLength(128)
            .Matches("[A-Z]").Matches("[a-z]").Matches("[0-9]");
        RuleFor(x => x.PasswordConfirm).Equal(x => x.Password);
        RuleFor(x => x.FirstName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.LastName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.PhoneNumber).Matches("^\\+[1-9][0-9]{7,14}$");
    }
}
