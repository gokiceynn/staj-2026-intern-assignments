using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Features.Reviews;

public sealed record ReviewPhotoDto(string PhotoId);
public sealed record ReviewUserDto(string Id, string DisplayName);
public sealed record ReviewDto(string Id, string ProductId, ReviewUserDto User, int Rating, string Comment,
    IReadOnlyList<ReviewPhotoDto> Photos, bool IsVerifiedPurchase, DateTime CreatedAtUtc, DateTime? UpdatedAtUtc);
public sealed record ReviewSummary(decimal AverageRating, int TotalReviewCount, IReadOnlyDictionary<int, int> RatingDistribution);
public sealed record ReviewPage(ReviewSummary Summary, PagedResult<ReviewDto> Reviews);
