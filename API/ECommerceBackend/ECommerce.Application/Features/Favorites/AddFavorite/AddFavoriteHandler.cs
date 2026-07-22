using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Domain.Shopping;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Favorites.AddFavorite;

public sealed class AddFavoriteHandler(IAppDbContext db, ICurrentUser currentUser, IClock clock)
{
    public async Task<Result> HandleAsync(AddFavoriteCommand command, CancellationToken ct)
    {
        if (!await db.Products.AnyAsync(x => x.Id == command.ProductId && x.IsActive, ct)) return Result.Failure(CommonErrors.NotFound);
        if (!await db.Favorites.AnyAsync(x => x.CustomerAccountId == currentUser.AccountId && x.ProductId == command.ProductId, ct))
        {
            db.Favorites.Add(new Favorite { CustomerAccountId = currentUser.AccountId, ProductId = command.ProductId, AddedAtUtc = clock.UtcNow });
            await db.SaveChangesAsync(ct);
        }
        return Result.Success();
    }
}
