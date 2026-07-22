namespace ECommerce.Api.Middleware;

public sealed class CorrelationIdMiddleware(
    RequestDelegate next,
    ILogger<CorrelationIdMiddleware> logger
)
{
    public async Task InvokeAsync(HttpContext context)
    {
        string id =
            context.Request.Headers.TryGetValue("X-Correlation-Id", out var value)
            && value.ToString().Length <= 100
                ? value.ToString()
                : Guid.NewGuid().ToString("N");
        context.TraceIdentifier = id;
        context.Response.Headers["X-Correlation-Id"] = id;
        using (logger.BeginScope(new Dictionary<string, object> { ["CorrelationId"] = id }))
            await next(context);
    }
}

