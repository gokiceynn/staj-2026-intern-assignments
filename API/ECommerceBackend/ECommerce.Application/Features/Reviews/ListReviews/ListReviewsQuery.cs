namespace ECommerce.Application.Features.Reviews.ListReviews;
public sealed record ListReviewsQuery(string ProductId, int Page = 1, int Size = 10, string SortBy = "newest");
