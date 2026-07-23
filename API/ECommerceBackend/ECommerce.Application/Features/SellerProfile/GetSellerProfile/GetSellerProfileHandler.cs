using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Application.Features.SellerProfile.GetSellerProfile;
public sealed class GetSellerProfileHandler(IAppDbContext db, ICurrentUser currentUser)
{
    public async Task<Result<SellerProfileDto>> HandleAsync(GetSellerProfileQuery query, CancellationToken ct)
    {
        SellerProfileDto? dto = await db.SellerProfiles.AsNoTracking().Where(x => x.AccountId == currentUser.AccountId)
            .Select(x => new SellerProfileDto(x.Id, x.StoreName, x.Description, x.LogoPhotoId, x.TaxNumber, x.TaxOffice,
                x.RatingAverage, x.IsActive, x.CreatedAtUtc)).SingleOrDefaultAsync(ct);
        return dto is null ? Result<SellerProfileDto>.Failure(CommonErrors.NotFound) : Result<SellerProfileDto>.Success(dto);
    }
}
