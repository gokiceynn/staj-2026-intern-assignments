using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Catalog;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Reviews.ListReviews;

public sealed class ListReviewsHandler(IAppDbContext db, IValidator<ListReviewsQuery> validator)
{
    public async Task<Result<ReviewPage>> HandleAsync(ListReviewsQuery query, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(query, ct);
        if (error is not null) return Result<ReviewPage>.Failure(error);
        IQueryable<Review> reviews = db.Reviews.AsNoTracking().Where(x => x.ProductId == query.ProductId && x.IsActive);
        long total = await reviews.LongCountAsync(ct);
        var distribution = await reviews.GroupBy(x => x.Rating).Select(x => new { x.Key, Count = x.Count() })
            .ToDictionaryAsync(x => x.Key, x => x.Count, ct);
        for (int i = 1; i <= 5; i++) distribution.TryAdd(i, 0);
        decimal average = total == 0 ? 0 : await reviews.AverageAsync(x => x.Rating, ct);
        reviews = query.SortBy switch
        {
            "oldest" => reviews.OrderBy(x => x.CreatedAtUtc),
            "rating_desc" => reviews.OrderByDescending(x => x.Rating).ThenByDescending(x => x.CreatedAtUtc),
            "rating_asc" => reviews.OrderBy(x => x.Rating).ThenByDescending(x => x.CreatedAtUtc),
            _ => reviews.OrderByDescending(x => x.CreatedAtUtc)
        };
        var items = await reviews.Skip((query.Page - 1) * query.Size).Take(query.Size)
            .Select(x => new ReviewDto(x.Id, x.ProductId,
                new ReviewUserDto(x.CustomerAccountId, x.CustomerAccount.FirstName + " " + x.CustomerAccount.LastName.Substring(0, 1) + "."),
                x.Rating, x.Comment, x.Photos.OrderBy(p => p.DisplayOrder).Select(p => new ReviewPhotoDto(p.PhotoId)).ToList(),
                true, x.CreatedAtUtc, x.UpdatedAtUtc)).ToListAsync(ct);
        return Result<ReviewPage>.Success(new(
            new ReviewSummary(Math.Round(average, 2), (int)total, distribution),
            new PagedResult<ReviewDto>(items, query.Page, query.Size, total)));
    }
}
