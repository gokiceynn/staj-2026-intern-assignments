using FluentValidation;
namespace ECommerce.Application.Features.SellerProfile.UpdateSellerProfile;
public sealed class UpdateSellerProfileValidator : AbstractValidator<UpdateSellerProfileCommand>
{
    public UpdateSellerProfileValidator()
    {
        RuleFor(x => x.StoreName).NotEmpty().MaximumLength(160);
        RuleFor(x => x.Description).MaximumLength(2000);
        RuleFor(x => x.LogoId).MaximumLength(40);
        RuleFor(x => x.TaxOffice).NotEmpty().MaximumLength(120);
    }
}
