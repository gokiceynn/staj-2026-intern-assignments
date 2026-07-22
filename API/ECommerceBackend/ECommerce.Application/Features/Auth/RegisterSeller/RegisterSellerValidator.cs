using FluentValidation;

namespace ECommerce.Application.Features.Auth.RegisterSeller;

public sealed class RegisterSellerValidator : AbstractValidator<RegisterSellerCommand>
{
    public RegisterSellerValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(254);
        RuleFor(x => x.Password).MinimumLength(12).MaximumLength(128).Matches("[A-Z]").Matches("[a-z]").Matches("[0-9]");
        RuleFor(x => x.PasswordConfirm).Equal(x => x.Password);
        RuleFor(x => x.FirstName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.LastName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.PhoneNumber).Matches("^\\+[1-9][0-9]{7,14}$");
        RuleFor(x => x.StoreName).NotEmpty().MaximumLength(160);
        RuleFor(x => x.TaxNumber).Matches("^[0-9]{10,11}$");
        RuleFor(x => x.TaxOffice).NotEmpty().MaximumLength(120);
    }
}
