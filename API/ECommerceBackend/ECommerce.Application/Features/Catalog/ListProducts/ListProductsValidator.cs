using FluentValidation;
namespace ECommerce.Application.Features.Catalog.ListProducts;
public sealed class ListProductsValidator : AbstractValidator<ListProductsQuery>
{
    private static readonly string[] Sorts = ["price_asc", "price_desc", "newest", "rating_desc"];
    public ListProductsValidator()
    {
        RuleFor(x => x.Page).GreaterThan(0);
        RuleFor(x => x.Size).InclusiveBetween(1, 100);
        RuleFor(x => x.Q).MaximumLength(200);
        RuleFor(x => x.MinPrice).GreaterThanOrEqualTo(0).When(x => x.MinPrice.HasValue);
        RuleFor(x => x.MaxPrice).GreaterThanOrEqualTo(x => x.MinPrice ?? 0).When(x => x.MaxPrice.HasValue);
        RuleFor(x => x.SortBy).Must(x => Sorts.Contains(x));
    }
}
