using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Catalog.GetProduct;

public sealed class GetProductHandler(IAppDbContext db)
{
    public async Task<Result<ProductDetail>> HandleAsync(GetProductQuery query, CancellationToken ct)
    {
        var item = await db.Products.AsNoTracking().Where(x => x.Id == query.Id && x.IsActive && x.SellerProfile.IsActive)
            .Select(x => new
            {
                Product = x,
                PhotoIds = x.Photos.OrderBy(p => p.DisplayOrder).Select(p => p.PhotoId).ToList(),
                Category = new CategorySummary(x.Category.Id, x.Category.Name, x.Category.IconPhotoId, x.Category.ParentCategoryId),
                Seller = new SellerSummary(x.SellerProfile.Id, x.SellerProfile.StoreName, x.SellerProfile.LogoPhotoId, x.SellerProfile.RatingAverage)
            }).SingleOrDefaultAsync(ct);
        if (item is null) return Result<ProductDetail>.Failure(CommonErrors.NotFound);
        IReadOnlyDictionary<string, string> features = JsonSerializer.Deserialize<Dictionary<string, string>>(item.Product.FeaturesJson)
            ?? new Dictionary<string, string>();
        string? primary = item.PhotoIds.FirstOrDefault();
        ProductDetail dto = new(item.Product.Id, item.Product.Title, item.Product.Description, item.Product.Price,
            item.Product.Stock, primary, item.PhotoIds, item.Product.RatingAverage, item.Product.ReviewCount,
            features, item.Product.CategoryId, item.Category, item.Seller, item.Product.IsActive,
            item.Product.CreatedAtUtc, item.Product.UpdatedAtUtc);
        return Result<ProductDetail>.Success(dto);
    }
}
