using ECommerce.Api.Extensions;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Features.Metadata.GetStatuses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace ECommerce.Api.Controllers.V1;
[ApiController, AllowAnonymous, Route("api/v1/metadata")]
public sealed class MetadataController(IClock clock) : ControllerBase
{
    [HttpGet("statuses")]
    public async Task<IActionResult> Statuses([FromServices] GetStatusesHandler h, CancellationToken ct) =>
        (await h.HandleAsync(new(), ct)).ToActionResult(this, clock, "Durum metadata bilgileri getirildi.");
}
