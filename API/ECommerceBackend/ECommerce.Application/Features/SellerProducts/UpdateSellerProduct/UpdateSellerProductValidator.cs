using FluentValidation;
namespace ECommerce.Application.Features.SellerProducts.UpdateSellerProduct;
public sealed class UpdateSellerProductValidator : AbstractValidator<UpdateSellerProductCommand>
{
    public UpdateSellerProductValidator()
    {
        RuleFor(x => x.Id).NotEmpty().MaximumLength(40);
        RuleFor(x => x.Title).NotEmpty().MaximumLength(240);
        RuleFor(x => x.Description).NotEmpty().MaximumLength(5000);
        RuleFor(x => x.Price).GreaterThan(0).LessThanOrEqualTo(1_000_000);
        RuleFor(x => x.Stock).InclusiveBetween(0, 1_000_000);
        RuleFor(x => x.CategoryId).NotEmpty().MaximumLength(40);
        RuleFor(x => x.PhotoIds).NotNull().Must(x => x.Count is >= 1 and <= 10 && x.Distinct().Count() == x.Count);
        RuleFor(x => x.Features).NotNull().Must(x => x.Count <= 50);
    }
}
