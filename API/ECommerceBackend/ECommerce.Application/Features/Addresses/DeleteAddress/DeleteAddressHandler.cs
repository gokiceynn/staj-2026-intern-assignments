using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Addresses.DeleteAddress;

public sealed class DeleteAddressHandler(IAppDbContext db, ICurrentUser currentUser, IClock clock)
{
    public async Task<Result> HandleAsync(DeleteAddressCommand command, CancellationToken ct)
    {
        var entity = await db.Addresses.SingleOrDefaultAsync(x => x.Id == command.Id && x.AccountId == currentUser.AccountId && x.IsActive, ct);
        if (entity is null) return Result.Failure(CommonErrors.NotFound);
        entity.IsActive = false; entity.DeletedAtUtc = clock.UtcNow; entity.UpdatedAtUtc = clock.UtcNow;
        await db.SaveChangesAsync(ct);
        return Result.Success();
    }
}
