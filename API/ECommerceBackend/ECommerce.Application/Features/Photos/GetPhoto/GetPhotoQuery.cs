namespace ECommerce.Application.Features.Photos.GetPhoto;
public sealed record GetPhotoQuery(string Id);
public sealed record GetPhotoResult(Stream Content, string ContentType, long Length);
