using System.Security.Claims;
using ECommerce.Api.Contracts.Common;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using Microsoft.AspNetCore.Authentication.JwtBearer;

namespace ECommerce.Api.Authentication;

public sealed class CustomJwtBearerEvents(ITokenRevocationChecker checker, IClock clock)
    : JwtBearerEvents
{
    public override async Task TokenValidated(TokenValidatedContext context)
    {
        ClaimsPrincipal principal = context.Principal!;
        string? sub = principal.FindFirstValue(ClaimNames.Subject),
            jti = principal.FindFirstValue(ClaimNames.JwtId),
            sid = principal.FindFirstValue(ClaimNames.SessionId),
            versionText = principal.FindFirstValue(ClaimNames.SecurityVersion);
        if (
            string.IsNullOrWhiteSpace(sub)
            || string.IsNullOrWhiteSpace(jti)
            || string.IsNullOrWhiteSpace(sid)
            || !int.TryParse(versionText, out int version)
        )
        {
            context.Fail("TOKEN_CLAIMS_INVALID");
            return;
        }
        if (
            !await checker.IsTokenValidAsync(
                sub,
                jti,
                sid,
                version,
                context.HttpContext.RequestAborted
            )
        )
            context.Fail("TOKEN_REVOKED");
    }

    public override async Task Challenge(JwtBearerChallengeContext context)
    {
        if (context.Response.HasStarted)
            return;
        context.HandleResponse();
        context.Response.StatusCode = 401;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(
            ApiResponse<object?>.Failure(
                "Authentication is required.",
                401,
                new Dictionary<string, string[]>
                {
                    ["UNAUTHORIZED"] =
                    [
                        "The access token is missing, invalid, expired or revoked.",
                    ],
                },
                clock.UtcNow
            )
        );
    }

    public override async Task Forbidden(ForbiddenContext context)
    {
        context.Response.StatusCode = 403;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(
            ApiResponse<object?>.Failure(
                "You are not allowed to perform this operation.",
                403,
                new Dictionary<string, string[]>
                {
                    ["FORBIDDEN"] = ["The authenticated role does not satisfy the policy."],
                },
                clock.UtcNow
            )
        );
    }
}

