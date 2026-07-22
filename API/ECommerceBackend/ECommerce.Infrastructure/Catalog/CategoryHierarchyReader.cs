using ECommerce.Application.Common.Abstractions;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Infrastructure.Catalog;
public sealed class CategoryHierarchyReader(AppDbContext db) : ICategoryHierarchyReader
{
    public async Task<IReadOnlyCollection<string>> GetSelfAndDescendantIdsAsync(string categoryId, CancellationToken ct)
    {
        return await db.Database.SqlQuery<string>($@"
            WITH RECURSIVE category_tree AS (
              SELECT id FROM categories WHERE id = {categoryId} AND is_active = TRUE
              UNION ALL
              SELECT c.id FROM categories c JOIN category_tree p ON c.parent_category_id = p.id WHERE c.is_active = TRUE
            ) SELECT id AS Value FROM category_tree").ToListAsync(ct);
    }
}
