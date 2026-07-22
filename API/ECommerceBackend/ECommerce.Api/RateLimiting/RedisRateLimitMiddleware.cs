using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using ECommerce.Api.Contracts.Common;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using StackExchange.Redis;
namespace ECommerce.Api.RateLimiting;
public sealed class RedisRateLimitMiddleware(RequestDelegate next, ILogger<RedisRateLimitMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context, ISecurityRedisStore redis, IClock clock)
    {
        RedisRateLimitAttribute? attribute = context.GetEndpoint()?.Metadata.GetMetadata<RedisRateLimitAttribute>();
        if (attribute is null) { await next(context); return; }
        if (!RateLimitPolicyRegistry.All.TryGetValue(attribute.Policy, out ApiRateLimitPolicy? policy))
            throw new InvalidOperationException($"Unknown rate limit policy: {attribute.Policy}");
        string ip = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        string? sub = context.User.FindFirstValue(ClaimNames.Subject);
        string partition = Sha256(sub is null ? $"ip:{ip}" : $"sub:{sub}:ip:{ip}");
        try
        {
            var decision = await redis.TryConsumeRateLimitAsync(policy.Rule, partition, context.RequestAborted);
            context.Response.Headers["RateLimit-Remaining"] = decision.Remaining.ToString(System.Globalization.CultureInfo.InvariantCulture);
            context.Response.Headers["RateLimit-Reset"] = decision.ResetUnixSeconds.ToString(System.Globalization.CultureInfo.InvariantCulture);
            if (!decision.IsAllowed)
            {
                context.Response.StatusCode = 429; context.Response.Headers["Retry-After"] = decision.RetryAfterSeconds.ToString();
                await context.Response.WriteAsJsonAsync(ApiResponse<object?>.Failure("Too many requests.", 429,
                    new Dictionary<string, string[]> { ["RATE_LIMITED"] = ["Retry after the indicated number of seconds."] }, clock.UtcNow)); return;
            }
        }
        catch (RedisException ex)
        {
            logger.LogWarning(ex, "Redis rate limiter failed for {Policy}.", attribute.Policy);
            if (policy.FailClosed)
            {
                context.Response.StatusCode = 503;
                await context.Response.WriteAsJsonAsync(ApiResponse<object?>.Failure("Security dependency is unavailable.", 503,
                    new Dictionary<string, string[]> { ["RATE_LIMIT_UNAVAILABLE"] = ["Try again later."] }, clock.UtcNow)); return;
            }
        }
        await next(context);
    }
    private static string Sha256(string value) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(value))).ToLowerInvariant();
}
