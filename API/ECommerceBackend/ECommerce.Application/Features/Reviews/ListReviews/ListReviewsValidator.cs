using FluentValidation;
namespace ECommerce.Application.Features.Reviews.ListReviews;
public sealed class ListReviewsValidator : AbstractValidator<ListReviewsQuery>
{
    private static readonly string[] Sorts = ["newest", "oldest", "rating_desc", "rating_asc"];
    public ListReviewsValidator()
    {
        RuleFor(x => x.ProductId).NotEmpty().MaximumLength(40);
        RuleFor(x => x.Page).GreaterThan(0);
        RuleFor(x => x.Size).InclusiveBetween(1, 100);
        RuleFor(x => x.SortBy).Must(x => Sorts.Contains(x));
    }
}
