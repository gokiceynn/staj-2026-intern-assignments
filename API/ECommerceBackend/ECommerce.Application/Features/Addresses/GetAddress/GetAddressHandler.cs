using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Addresses.GetAddress;

public sealed class GetAddressHandler(IAppDbContext db, ICurrentUser currentUser)
{
    public async Task<Result<AddressDto>> HandleAsync(GetAddressQuery query, CancellationToken ct)
    {
        AddressDto? item = await db.Addresses.AsNoTracking()
            .Where(x => x.Id == query.Id && x.AccountId == currentUser.AccountId && x.IsActive)
            .Select(x => new AddressDto(x.Id, x.Title, x.AddressLine, x.City, x.District, x.ZipCode, x.PhoneNumber))
            .SingleOrDefaultAsync(ct);
        return item is null ? Result<AddressDto>.Failure(CommonErrors.NotFound) : Result<AddressDto>.Success(item);
    }
}
