using FluentValidation;
namespace ECommerce.Application.Features.Reviews.UpdateReview;
public sealed class UpdateReviewValidator : AbstractValidator<UpdateReviewCommand>
{
    public UpdateReviewValidator()
    {
        RuleFor(x => x.ProductId).NotEmpty().MaximumLength(40);
        RuleFor(x => x.ReviewId).NotEmpty().MaximumLength(40);
        RuleFor(x => x.Rating).InclusiveBetween(1, 5);
        RuleFor(x => x.Comment).MinimumLength(10).MaximumLength(1000);
        RuleFor(x => x.PhotoIds).NotNull().Must(x => x.Count <= 5 && x.Distinct().Count() == x.Count);
    }
}
