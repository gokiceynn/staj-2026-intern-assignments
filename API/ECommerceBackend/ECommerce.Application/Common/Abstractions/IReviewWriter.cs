using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Reviews;

namespace ECommerce.Application.Common.Abstractions;

public interface IReviewWriter
{
    Task<Result<ReviewDto>> CreateAsync(string accountId, string productId, int rating, string comment, IReadOnlyList<string> photoIds, CancellationToken ct);
    Task<Result<ReviewDto>> UpdateAsync(string accountId, string productId, string reviewId, int rating, string comment, IReadOnlyList<string> photoIds, CancellationToken ct);
    Task<Result> DeleteAsync(string accountId, string productId, string reviewId, CancellationToken ct);
}
