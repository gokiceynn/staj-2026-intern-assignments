namespace ECommerce.Application.Features.Reviews.CreateReview;
public sealed record CreateReviewCommand(string ProductId, int Rating, string Comment, IReadOnlyList<string> PhotoIds);
