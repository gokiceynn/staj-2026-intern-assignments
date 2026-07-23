using ECommerce.Api.Contracts.Common;
using ECommerce.Application.Common.Abstractions;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Api.Middleware;

public sealed class ExceptionHandlingMiddleware(
    RequestDelegate next,
    ILogger<ExceptionHandlingMiddleware> logger
)
{
    public async Task InvokeAsync(HttpContext context, IClock clock)
    {
        try
        {
            await next(context);
        }
        catch (DbUpdateConcurrencyException ex)
        {
            logger.LogWarning(ex, "Concurrency conflict.");
            await WriteAsync(
                context,
                clock,
                409,
                "CONFLICT",
                "The resource was changed by another request."
            );
        }
        catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested) { }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled API error.");
            await WriteAsync(
                context,
                clock,
                500,
                "INTERNAL_ERROR",
                "An unexpected error occurred."
            );
        }
    }

    private static async Task WriteAsync(
        HttpContext context,
        IClock clock,
        int status,
        string code,
        string message
    )
    {
        if (context.Response.HasStarted)
            throw new InvalidOperationException("Response already started.");
        context.Response.StatusCode = status;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(
            ApiResponse<object?>.Failure(
                message,
                status,
                new Dictionary<string, string[]> { [code] = [message] },
                clock.UtcNow
            )
        );
    }
}

