using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Catalog.GetCategories;

public sealed class GetCategoriesHandler(IAppDbContext db, ICacheService cache)
{
    public async Task<Result<IReadOnlyList<CategoryNode>>> HandleAsync(GetCategoriesQuery query, CancellationToken ct)
    {
        const string key = "catalog:categories:v1";
        IReadOnlyList<CategoryNode>? cached = await cache.GetAsync<IReadOnlyList<CategoryNode>>(key, ct);
        if (cached is not null) return Result<IReadOnlyList<CategoryNode>>.Success(cached);

        var categories = await db.Categories.AsNoTracking().Where(x => x.IsActive).OrderBy(x => x.SortOrder)
            .Select(x => new { x.Id, x.Name, x.Slug, x.IconPhotoId, x.ParentCategoryId }).ToListAsync(ct);
        var counts = await db.Products.AsNoTracking().Where(x => x.IsActive)
            .GroupBy(x => x.CategoryId).Select(x => new { Id = x.Key, Count = x.Count() }).ToDictionaryAsync(x => x.Id, x => x.Count, ct);

        List<CategoryNode> Build(string? parentId) => categories.Where(x => x.ParentCategoryId == parentId)
            .Select(x =>
            {
                List<CategoryNode> children = Build(x.Id);
                int count = counts.GetValueOrDefault(x.Id) + children.Sum(c => c.ProductCount);
                return new CategoryNode(x.Id, x.Name, x.Slug, x.IconPhotoId, x.ParentCategoryId, count, children);
            }).ToList();

        IReadOnlyList<CategoryNode> result = Build(null);
        await cache.SetAsync(key, result, TimeSpan.FromMinutes(10), ct);
        return Result<IReadOnlyList<CategoryNode>>.Success(result);
    }
}
