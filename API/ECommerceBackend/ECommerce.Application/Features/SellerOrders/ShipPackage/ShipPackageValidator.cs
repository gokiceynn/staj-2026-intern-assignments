using FluentValidation;
namespace ECommerce.Application.Features.SellerOrders.ShipPackage;
public sealed class ShipPackageValidator : AbstractValidator<ShipPackageCommand>
{
    public ShipPackageValidator()
    {
        RuleFor(x => x.PackageId).NotEmpty().MaximumLength(40);
        RuleFor(x => x.CarrierId).NotEmpty().MaximumLength(40);
        RuleFor(x => x.TrackingNumber).NotEmpty().MaximumLength(120).Matches("^[A-Za-z0-9_-]+$");
    }
}
