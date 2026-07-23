using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Favorites.RemoveFavorite;

public sealed class RemoveFavoriteHandler(IAppDbContext db, ICurrentUser currentUser)
{
    public async Task<Result> HandleAsync(RemoveFavoriteCommand command, CancellationToken ct)
    {
        var item = await db.Favorites.SingleOrDefaultAsync(x => x.CustomerAccountId == currentUser.AccountId && x.ProductId == command.ProductId, ct);
        if (item is not null) { db.Favorites.Remove(item); await db.SaveChangesAsync(ct); }
        return Result.Success();
    }
}
