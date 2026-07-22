using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Media;
using FluentValidation;

namespace ECommerce.Application.Features.Photos.UploadPhoto;

public sealed class UploadPhotoHandler(
    IAppDbContext db, IFileStorage storage, ICurrentUser currentUser, IIdGenerator ids,
    IClock clock, IValidator<UploadPhotoCommand> validator)
{
    public async Task<Result<UploadPhotoResult>> HandleAsync(UploadPhotoCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result<UploadPhotoResult>.Failure(error);
        StoredFile stored = await storage.SaveAsync(command.Content, command.ContentType, ct);
        Photo photo = new()
        {
            Id = ids.NewId("img"), OwnerAccountId = currentUser.AccountId, Purpose = PhotoPurpose.Unknown,
            StorageProvider = "Local", StorageKey = stored.Key, OriginalFileName = Path.GetFileName(command.FileName),
            ContentType = command.ContentType, Sha256Hash = stored.Sha256Hash, FileSizeBytes = stored.SizeBytes,
            Width = stored.Width, Height = stored.Height, CreatedAtUtc = clock.UtcNow
        };
        db.Photos.Add(photo);
        try { await db.SaveChangesAsync(ct); }
        catch { await storage.DeleteAsync(stored.Key, CancellationToken.None); throw; }
        return Result<UploadPhotoResult>.Success(new(photo.Id, photo.CreatedAtUtc));
    }
}
