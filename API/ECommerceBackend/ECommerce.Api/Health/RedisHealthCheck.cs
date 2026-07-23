using Microsoft.Extensions.Diagnostics.HealthChecks;
using StackExchange.Redis;

namespace ECommerce.Api.Health;

public sealed class RedisHealthCheck(IConnectionMultiplexer redis) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken ct = default
    )
    {
        try
        {
            TimeSpan latency = await redis.GetDatabase().PingAsync().WaitAsync(ct);
            return HealthCheckResult.Healthy(
                "Redis is reachable.",
                new Dictionary<string, object> { ["latencyMs"] = latency.TotalMilliseconds }
            );
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Redis is unavailable.", ex);
        }
    }
}

