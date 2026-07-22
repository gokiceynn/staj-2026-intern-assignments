using ECommerce.Application.Common.Redis;
namespace ECommerce.Application.Common.Abstractions;
public interface ILoginAttemptLimiter { Task<RateLimitDecision> ConsumeAsync(string normalizedEmail, CancellationToken ct); }
