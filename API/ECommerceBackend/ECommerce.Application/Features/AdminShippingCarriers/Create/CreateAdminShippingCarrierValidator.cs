using FluentValidation;
namespace ECommerce.Application.Features.AdminShippingCarriers.Create;
public sealed class CreateAdminShippingCarrierValidator : AbstractValidator<CreateAdminShippingCarrierCommand>
{
    public CreateAdminShippingCarrierValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(160);
        RuleFor(x => x.Code).NotEmpty().MaximumLength(40).Matches("^[A-Z0-9_]+$");
        RuleFor(x => x.LogoId).MaximumLength(40);
        RuleFor(x => x.FlatFee).InclusiveBetween(0, 100_000);
        RuleFor(x => x.EstimatedDeliveryDays).InclusiveBetween(1, 365);
        RuleFor(x => x.TrackingUrlTemplate).NotEmpty().MaximumLength(500).Must(x => x.Contains("{trackingNumber}", StringComparison.Ordinal));
    }
}
