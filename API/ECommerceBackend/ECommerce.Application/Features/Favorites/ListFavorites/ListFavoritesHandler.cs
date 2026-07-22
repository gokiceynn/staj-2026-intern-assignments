using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Application.Features.Catalog;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Favorites.ListFavorites;

public sealed class ListFavoritesHandler(IAppDbContext db, ICurrentUser currentUser, IValidator<ListFavoritesQuery> validator)
{
    public async Task<Result<ListFavoritesResult>> HandleAsync(ListFavoritesQuery query, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(query, ct);
        if (error is not null) return Result<ListFavoritesResult>.Failure(error);
        var source = db.Favorites.AsNoTracking().Where(x => x.CustomerAccountId == currentUser.AccountId && x.Product.IsActive)
            .OrderByDescending(x => x.AddedAtUtc);
        long total = await source.LongCountAsync(ct);
        var items = await source.Skip((query.Page - 1) * query.Size).Take(query.Size).Select(x => new ProductCard(
            x.Product.Id, x.Product.Title, x.Product.Description, x.Product.Price, x.Product.Stock,
            x.Product.Photos.OrderBy(p => p.DisplayOrder).Select(p => p.PhotoId).FirstOrDefault(), x.Product.RatingAverage,
            new CategorySummary(x.Product.Category.Id, x.Product.Category.Name, x.Product.Category.IconPhotoId, x.Product.Category.ParentCategoryId),
            new SellerSummary(x.Product.SellerProfile.Id, x.Product.SellerProfile.StoreName, x.Product.SellerProfile.LogoPhotoId, x.Product.SellerProfile.RatingAverage)))
            .ToListAsync(ct);
        return Result<ListFavoritesResult>.Success(new(new PagedResult<ProductCard>(items, query.Page, query.Size, total)));
    }
}
