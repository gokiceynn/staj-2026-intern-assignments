using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Addresses.ListAddresses;

public sealed class ListAddressesHandler(IAppDbContext db, ICurrentUser currentUser)
{
    public async Task<Result<ListAddressesResult>> HandleAsync(ListAddressesQuery query, CancellationToken ct)
    {
        var items = await db.Addresses.AsNoTracking()
            .Where(x => x.AccountId == currentUser.AccountId && x.IsActive)
            .OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new AddressDto(x.Id, x.Title, x.AddressLine, x.City, x.District, x.ZipCode, x.PhoneNumber))
            .ToListAsync(ct);
        return Result<ListAddressesResult>.Success(new(items));
    }
}
