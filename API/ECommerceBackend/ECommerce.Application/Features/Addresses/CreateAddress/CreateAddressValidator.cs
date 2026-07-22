using FluentValidation;
namespace ECommerce.Application.Features.Addresses.CreateAddress;
public sealed class CreateAddressValidator : AbstractValidator<CreateAddressCommand>
{
    public CreateAddressValidator()
    {
        RuleFor(x => x.Title).NotEmpty().MaximumLength(80);
        RuleFor(x => x.AddressLine).NotEmpty().MaximumLength(500);
        RuleFor(x => x.City).NotEmpty().MaximumLength(100);
        RuleFor(x => x.District).NotEmpty().MaximumLength(100);
        RuleFor(x => x.ZipCode).NotEmpty().MaximumLength(20);
        RuleFor(x => x.PhoneNumber).Matches("^\\+[1-9][0-9]{7,14}$");
    }
}
