using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Catalog;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Catalog.ListProducts;

public sealed class ListProductsHandler(IAppDbContext db, ICategoryHierarchyReader hierarchy, IValidator<ListProductsQuery> validator)
{
    public async Task<Result<ListProductsResult>> HandleAsync(ListProductsQuery query, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(query, ct);
        if (error is not null) return Result<ListProductsResult>.Failure(error);
        IQueryable<Product> products = db.Products.AsNoTracking().Where(x => x.IsActive && x.SellerProfile.IsActive);
        if (!string.IsNullOrWhiteSpace(query.Q))
        {
            string term = query.Q.Trim();
            products = products.Where(x => EF.Functions.Like(x.Title, $"%{term}%") || EF.Functions.Like(x.Description, $"%{term}%"));
        }
        if (!string.IsNullOrWhiteSpace(query.CategoryId))
        {
            IReadOnlyCollection<string> ids = await hierarchy.GetSelfAndDescendantIdsAsync(query.CategoryId, ct);
            products = products.Where(x => ids.Contains(x.CategoryId));
        }
        if (!string.IsNullOrWhiteSpace(query.SellerId)) products = products.Where(x => x.SellerProfileId == query.SellerId);
        if (query.MinPrice.HasValue) products = products.Where(x => x.Price >= query.MinPrice.Value);
        if (query.MaxPrice.HasValue) products = products.Where(x => x.Price <= query.MaxPrice.Value);
        if (query.InStock == true) products = products.Where(x => x.Stock > 0);
        products = query.SortBy switch
        {
            "price_asc" => products.OrderBy(x => x.Price).ThenBy(x => x.Id),
            "price_desc" => products.OrderByDescending(x => x.Price).ThenBy(x => x.Id),
            "rating_desc" => products.OrderByDescending(x => x.RatingAverage).ThenBy(x => x.Id),
            _ => products.OrderByDescending(x => x.CreatedAtUtc).ThenBy(x => x.Id)
        };

        long total = await products.LongCountAsync(ct);
        var items = await products.Skip((query.Page - 1) * query.Size).Take(query.Size)
            .Select(x => new ProductCard(x.Id, x.Title, x.Description, x.Price, x.Stock,
                x.Photos.OrderBy(p => p.DisplayOrder).Select(p => p.PhotoId).FirstOrDefault(), x.RatingAverage,
                new CategorySummary(x.Category.Id, x.Category.Name, x.Category.IconPhotoId, x.Category.ParentCategoryId),
                new SellerSummary(x.SellerProfile.Id, x.SellerProfile.StoreName, x.SellerProfile.LogoPhotoId, x.SellerProfile.RatingAverage)))
            .ToListAsync(ct);
        return Result<ListProductsResult>.Success(new(new PagedResult<ProductCard>(items, query.Page, query.Size, total)));
    }
}
