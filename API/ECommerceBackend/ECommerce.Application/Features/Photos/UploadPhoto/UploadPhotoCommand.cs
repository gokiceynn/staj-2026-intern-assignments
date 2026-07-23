namespace ECommerce.Application.Features.Photos.UploadPhoto;
public sealed record UploadPhotoCommand(Stream Content, string FileName, string ContentType, long Length);
public sealed record UploadPhotoResult(string PhotoId, DateTime UploadedAtUtc);
