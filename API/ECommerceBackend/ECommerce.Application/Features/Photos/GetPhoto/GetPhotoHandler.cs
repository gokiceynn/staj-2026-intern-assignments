using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Photos.GetPhoto;

public sealed class GetPhotoHandler(IAppDbContext db, IFileStorage storage, ICurrentUser currentUser)
{
    public async Task<Result<GetPhotoResult>> HandleAsync(GetPhotoQuery query, CancellationToken ct)
    {
        var photo = await db.Photos.AsNoTracking().SingleOrDefaultAsync(
            x => x.Id == query.Id && x.DeletedAtUtc == null && (x.IsLinked || x.OwnerAccountId == currentUser.AccountId), ct);
        if (photo is null) return Result<GetPhotoResult>.Failure(CommonErrors.NotFound);
        StoredFileContent? file = await storage.GetAsync(photo.StorageKey, ct);
        return file is null
            ? Result<GetPhotoResult>.Failure(CommonErrors.NotFound)
            : Result<GetPhotoResult>.Success(new(file.Content, photo.ContentType, file.SizeBytes));
    }
}
