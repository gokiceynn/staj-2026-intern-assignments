using ECommerce.Api.Extensions;
using ECommerce.Api.RateLimiting;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Application.Features.Photos.GetPhoto;
using ECommerce.Application.Features.Photos.UploadPhoto;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace ECommerce.Api.Controllers.V1;
[ApiController, Route("api/v1/photos")]
public sealed class PhotosController(IClock clock) : ControllerBase
{
    [Authorize, HttpPost, RequestSizeLimit(5 * 1024 * 1024), RedisRateLimit(RateLimitPolicyNames.Upload)]
    public async Task<IActionResult> Upload(IFormFile file, [FromServices] UploadPhotoHandler h, CancellationToken ct)
    {
        await using Stream stream = file.OpenReadStream();
        return (await h.HandleAsync(new(stream, file.FileName, file.ContentType, file.Length), ct))
            .ToActionResult(this, clock, "Fotoğraf başarıyla yüklendi.", StatusCodes.Status201Created);
    }
    [AllowAnonymous, HttpGet("{id}")]
    public async Task<IActionResult> Get(string id, [FromServices] GetPhotoHandler h, CancellationToken ct)
    {
        var result = await h.HandleAsync(new(id), ct);
        return result.IsSuccess ? File(result.Value!.Content, result.Value.ContentType, enableRangeProcessing: true)
            : result.ToActionResult(this, clock, "Fotoğraf getirildi.");
    }
}
