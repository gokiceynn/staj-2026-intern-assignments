using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Reviews;
using ECommerce.Domain.Catalog;
using ECommerce.Domain.Common.Enums;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Infrastructure.Catalog;
public sealed class ReviewWriter(AppDbContext db, ITransactionRunner transactions, IIdGenerator ids, IClock clock) : IReviewWriter
{
    public Task<Result<ReviewDto>> CreateAsync(string accountId, string productId, int rating, string comment, IReadOnlyList<string> photoIds, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            bool purchased = await db.OrderItems.AnyAsync(x => x.ProductId == productId && x.Order.CustomerAccountId == accountId && x.OrderPackage.Status == PackageStatus.Delivered, token);
            if (!purchased) return Result<ReviewDto>.Failure(new Error("VERIFIED_PURCHASE_REQUIRED", "Only delivered purchases can be reviewed."));
            if (await db.Reviews.AnyAsync(x => x.ProductId == productId && x.CustomerAccountId == accountId, token))
                return Result<ReviewDto>.Failure(new Error("REVIEW_ALREADY_EXISTS", "This product has already been reviewed."));
            Product? product = await db.Products.SingleOrDefaultAsync(x => x.Id == productId, token);
            if (product is null) return Result<ReviewDto>.Failure(CommonErrors.NotFound);
            Result<List<ReviewPhoto>> links = await BuildLinksAsync(accountId, ids.NewId("rev"), photoIds, token);
            if (!links.IsSuccess) return Result<ReviewDto>.Failure(links.Error!);
            Review review = new() { Id = links.Value!.FirstOrDefault()?.ReviewId ?? ids.NewId("rev"), ProductId = productId,
                CustomerAccountId = accountId, Rating = rating, Comment = comment, IsActive = true, CreatedAtUtc = clock.UtcNow };
            foreach (ReviewPhoto link in links.Value) { link.ReviewId = review.Id; review.Photos.Add(link); }
            db.Reviews.Add(review); await db.SaveChangesAsync(token); await RefreshAggregateAsync(product, token);
            await db.Entry(review).Reference(x => x.CustomerAccount).LoadAsync(token);
            return Result<ReviewDto>.Success(Map(review));
        }, System.Data.IsolationLevel.Serializable, ct);

    public Task<Result<ReviewDto>> UpdateAsync(string accountId, string productId, string reviewId, int rating, string comment, IReadOnlyList<string> photoIds, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            Review? review = await db.Reviews.Include(x => x.Photos).Include(x => x.CustomerAccount)
                .SingleOrDefaultAsync(x => x.Id == reviewId && x.ProductId == productId && x.CustomerAccountId == accountId && x.IsActive, token);
            if (review is null) return Result<ReviewDto>.Failure(CommonErrors.NotFound);
            Product product = await db.Products.SingleAsync(x => x.Id == productId, token);
            Result<List<ReviewPhoto>> links = await BuildLinksAsync(accountId, review.Id, photoIds, token);
            if (!links.IsSuccess) return Result<ReviewDto>.Failure(links.Error!);
            db.ReviewPhotos.RemoveRange(review.Photos); review.Photos.Clear();
            foreach (ReviewPhoto link in links.Value!) review.Photos.Add(link);
            review.Rating = rating; review.Comment = comment; review.UpdatedAtUtc = clock.UtcNow;
            await db.SaveChangesAsync(token); await RefreshAggregateAsync(product, token);
            return Result<ReviewDto>.Success(Map(review));
        }, System.Data.IsolationLevel.Serializable, ct);

    public Task<Result> DeleteAsync(string accountId, string productId, string reviewId, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            Review? review = await db.Reviews.SingleOrDefaultAsync(x => x.Id == reviewId && x.ProductId == productId && x.CustomerAccountId == accountId && x.IsActive, token);
            if (review is null) return Result.Failure(CommonErrors.NotFound);
            Product product = await db.Products.SingleAsync(x => x.Id == productId, token);
            review.IsActive = false; review.DeletedAtUtc = clock.UtcNow; review.UpdatedAtUtc = clock.UtcNow;
            await db.SaveChangesAsync(token); await RefreshAggregateAsync(product, token); return Result.Success();
        }, System.Data.IsolationLevel.Serializable, ct);

    private async Task<Result<List<ReviewPhoto>>> BuildLinksAsync(string ownerId, string reviewId, IReadOnlyList<string> photoIds, CancellationToken ct)
    {
        var photos = await db.Photos.Where(x => photoIds.Contains(x.Id) && x.OwnerAccountId == ownerId && x.DeletedAtUtc == null).ToListAsync(ct);
        if (photos.Count != photoIds.Count) return Result<List<ReviewPhoto>>.Failure(CommonErrors.NotFound);
        DateTime now = clock.UtcNow;
        foreach (var photo in photos) { photo.IsLinked = true; photo.LinkedAtUtc = now; photo.Purpose = PhotoPurpose.Review; }
        return Result<List<ReviewPhoto>>.Success(photoIds.Select((id, index) => new ReviewPhoto
            { ReviewId = reviewId, PhotoId = id, DisplayOrder = index, CreatedAtUtc = now }).ToList());
    }

    private async Task RefreshAggregateAsync(Product product, CancellationToken ct)
    {
        var ratings = db.Reviews.Where(x => x.ProductId == product.Id && x.IsActive);
        product.ReviewCount = await ratings.CountAsync(ct);
        product.RatingAverage = product.ReviewCount == 0 ? 0 : Math.Round(await ratings.AverageAsync(x => x.Rating, ct), 2);
        await db.SaveChangesAsync(ct);
    }

    private static ReviewDto Map(Review x) => new(x.Id, x.ProductId,
        new ReviewUserDto(x.CustomerAccountId, x.CustomerAccount.FirstName + " " + x.CustomerAccount.LastName[..1] + "."),
        x.Rating, x.Comment, x.Photos.OrderBy(p => p.DisplayOrder).Select(p => new ReviewPhotoDto(p.PhotoId)).ToList(),
        true, x.CreatedAtUtc, x.UpdatedAtUtc);
}
