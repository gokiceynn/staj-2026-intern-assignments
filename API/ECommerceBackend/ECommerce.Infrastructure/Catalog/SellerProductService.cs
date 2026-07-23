using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Catalog;
using ECommerce.Application.Features.SellerProducts;
using ECommerce.Domain.Catalog;
using ECommerce.Domain.Common.Enums;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Infrastructure.Catalog;
public sealed class SellerProductService(AppDbContext db, ITransactionRunner transactions, IIdGenerator ids, IClock clock) : ISellerProductService
{
    public async Task<Result<SellerProductPage>> ListAsync(string accountId, int page, int size, string? q, bool? isActive, CancellationToken ct)
    {
        string? sellerId = await SellerIdAsync(accountId, ct); if (sellerId is null) return Result<SellerProductPage>.Failure(CommonErrors.NotFound);
        var source = db.Products.AsNoTracking().Where(x => x.SellerProfileId == sellerId);
        if (!string.IsNullOrWhiteSpace(q)) source = source.Where(x => EF.Functions.Like(x.Title, $"%{q.Trim()}%"));
        if (isActive.HasValue) source = source.Where(x => x.IsActive == isActive.Value);
        long total = await source.LongCountAsync(ct);
        var items = await source.OrderByDescending(x => x.CreatedAtUtc).Skip((page - 1) * size).Take(size).Select(x =>
            new SellerProductCard(new ProductCard(x.Id, x.Title, x.Description, x.Price, x.Stock,
                x.Photos.OrderBy(p => p.DisplayOrder).Select(p => p.PhotoId).FirstOrDefault(), x.RatingAverage,
                new CategorySummary(x.Category.Id, x.Category.Name, x.Category.IconPhotoId, x.Category.ParentCategoryId),
                new SellerSummary(x.SellerProfile.Id, x.SellerProfile.StoreName, x.SellerProfile.LogoPhotoId, x.SellerProfile.RatingAverage)), x.IsActive)).ToListAsync(ct);
        return Result<SellerProductPage>.Success(new(new PagedResult<SellerProductCard>(items, page, size, total)));
    }

    public async Task<Result<SellerProductDetail>> GetAsync(string accountId, string productId, CancellationToken ct)
    { string? sellerId = await SellerIdAsync(accountId, ct); return sellerId is null ? Result<SellerProductDetail>.Failure(CommonErrors.NotFound) : await LoadDetailAsync(sellerId, productId, ct); }

    public Task<Result<SellerProductDetail>> CreateAsync(string accountId, ProductWriteModel model, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            string? sellerId = await SellerIdAsync(accountId, token); if (sellerId is null) return Result<SellerProductDetail>.Failure(CommonErrors.NotFound);
            if (!await db.Categories.AnyAsync(x => x.Id == model.CategoryId && x.IsActive, token)) return Result<SellerProductDetail>.Failure(CommonErrors.NotFound);
            Result<List<ProductPhoto>> links = await BuildPhotoLinksAsync(accountId, ids.NewId("prod"), model.PhotoIds, token);
            if (!links.IsSuccess) return Result<SellerProductDetail>.Failure(links.Error!);
            Product product = new() { Id = links.Value![0].ProductId, SellerProfileId = sellerId, CategoryId = model.CategoryId,
                Title = model.Title.Trim(), Description = model.Description.Trim(), Price = model.Price, Stock = model.Stock,
                FeaturesJson = JsonSerializer.Serialize(model.Features), IsActive = model.IsActive, CreatedAtUtc = clock.UtcNow };
            foreach (ProductPhoto link in links.Value) product.Photos.Add(link);
            db.Products.Add(product); await db.SaveChangesAsync(token); return await LoadDetailAsync(sellerId, product.Id, token);
        }, System.Data.IsolationLevel.ReadCommitted, ct);

    public Task<Result<SellerProductDetail>> UpdateAsync(string accountId, string productId, ProductWriteModel model, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            string? sellerId = await SellerIdAsync(accountId, token); if (sellerId is null) return Result<SellerProductDetail>.Failure(CommonErrors.NotFound);
            Product? product = await db.Products.Include(x => x.Photos).SingleOrDefaultAsync(x => x.Id == productId && x.SellerProfileId == sellerId, token);
            if (product is null || !await db.Categories.AnyAsync(x => x.Id == model.CategoryId && x.IsActive, token)) return Result<SellerProductDetail>.Failure(CommonErrors.NotFound);
            Result<List<ProductPhoto>> links = await BuildPhotoLinksAsync(accountId, product.Id, model.PhotoIds, token);
            if (!links.IsSuccess) return Result<SellerProductDetail>.Failure(links.Error!);
            db.ProductPhotos.RemoveRange(product.Photos); product.Photos.Clear(); foreach (var link in links.Value!) product.Photos.Add(link);
            product.Title = model.Title.Trim(); product.Description = model.Description.Trim(); product.Price = model.Price;
            product.Stock = model.Stock; product.CategoryId = model.CategoryId; product.FeaturesJson = JsonSerializer.Serialize(model.Features);
            product.IsActive = model.IsActive; product.DeactivatedAtUtc = model.IsActive ? null : clock.UtcNow; product.UpdatedAtUtc = clock.UtcNow;
            await db.SaveChangesAsync(token); return await LoadDetailAsync(sellerId, product.Id, token);
        }, System.Data.IsolationLevel.Serializable, ct);

    public async Task<Result> DeleteAsync(string accountId, string productId, CancellationToken ct)
    {
        string? sellerId = await SellerIdAsync(accountId, ct);
        Product? product = await db.Products.SingleOrDefaultAsync(x => x.Id == productId && x.SellerProfileId == sellerId, ct);
        if (product is null) return Result.Failure(CommonErrors.NotFound);
        product.IsActive = false; product.DeactivatedAtUtc = clock.UtcNow; product.UpdatedAtUtc = clock.UtcNow;
        await db.SaveChangesAsync(ct); return Result.Success();
    }

    private Task<string?> SellerIdAsync(string accountId, CancellationToken ct) => db.SellerProfiles.Where(x => x.AccountId == accountId && x.IsActive).Select(x => x.Id).SingleOrDefaultAsync(ct);
    private async Task<Result<List<ProductPhoto>>> BuildPhotoLinksAsync(string accountId, string productId, IReadOnlyList<string> idsToLink, CancellationToken ct)
    {
        var photos = await db.Photos.Where(x => idsToLink.Contains(x.Id) && x.OwnerAccountId == accountId && x.DeletedAtUtc == null).ToListAsync(ct);
        if (photos.Count != idsToLink.Count) return Result<List<ProductPhoto>>.Failure(CommonErrors.NotFound);
        foreach (var p in photos) { p.IsLinked = true; p.LinkedAtUtc = clock.UtcNow; p.Purpose = PhotoPurpose.Product; }
        return Result<List<ProductPhoto>>.Success(idsToLink.Select((id, i) => new ProductPhoto { ProductId = productId, PhotoId = id, DisplayOrder = i, CreatedAtUtc = clock.UtcNow }).ToList());
    }
    private async Task<Result<SellerProductDetail>> LoadDetailAsync(string sellerId, string productId, CancellationToken ct)
    {
        var x = await db.Products.AsNoTracking().Include(p => p.Photos).Include(p => p.Category)
            .SingleOrDefaultAsync(p => p.Id == productId && p.SellerProfileId == sellerId, ct);
        if (x is null) return Result<SellerProductDetail>.Failure(CommonErrors.NotFound);
        var photos = x.Photos.OrderBy(p => p.DisplayOrder).Select(p => p.PhotoId).ToList();
        return Result<SellerProductDetail>.Success(new(x.Id, x.Title, x.Description, x.Price, x.Stock, photos.FirstOrDefault(), photos,
            x.RatingAverage, JsonSerializer.Deserialize<Dictionary<string, string>>(x.FeaturesJson) ?? [], x.CategoryId,
            new CategorySummary(x.Category.Id, x.Category.Name, x.Category.IconPhotoId, x.Category.ParentCategoryId),
            x.IsActive, x.CreatedAtUtc, x.UpdatedAtUtc));
    }
}
