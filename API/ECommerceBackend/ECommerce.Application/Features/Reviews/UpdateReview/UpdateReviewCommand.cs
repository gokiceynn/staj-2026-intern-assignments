namespace ECommerce.Application.Features.Reviews.UpdateReview;
public sealed record UpdateReviewCommand(string ProductId, string ReviewId, int Rating, string Comment, IReadOnlyList<string> PhotoIds);
