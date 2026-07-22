using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Common.Enums;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Application.Features.SellerProfile.UpdateSellerProfile;
public sealed class UpdateSellerProfileHandler(IAppDbContext db, ICurrentUser currentUser, IClock clock, IValidator<UpdateSellerProfileCommand> validator)
{
    public async Task<Result<SellerProfileDto>> HandleAsync(UpdateSellerProfileCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result<SellerProfileDto>.Failure(error);
        var seller = await db.SellerProfiles.SingleOrDefaultAsync(x => x.AccountId == currentUser.AccountId, ct);
        if (seller is null) return Result<SellerProfileDto>.Failure(CommonErrors.NotFound);
        if (command.LogoId is not null)
        {
            var photo = await db.Photos.SingleOrDefaultAsync(x => x.Id == command.LogoId && x.OwnerAccountId == currentUser.AccountId && x.DeletedAtUtc == null, ct);
            if (photo is null) return Result<SellerProfileDto>.Failure(CommonErrors.NotFound);
            photo.IsLinked = true; photo.LinkedAtUtc = clock.UtcNow; photo.Purpose = PhotoPurpose.StoreLogo;
        }
        seller.StoreName = command.StoreName.Trim(); seller.Description = command.Description.Trim();
        seller.LogoPhotoId = command.LogoId; seller.TaxOffice = command.TaxOffice.Trim(); seller.UpdatedAtUtc = clock.UtcNow;
        await db.SaveChangesAsync(ct);
        return Result<SellerProfileDto>.Success(new(seller.Id, seller.StoreName, seller.Description, seller.LogoPhotoId,
            seller.TaxNumber, seller.TaxOffice, seller.RatingAverage, seller.IsActive, seller.CreatedAtUtc));
    }
}
