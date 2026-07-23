namespace ECommerce.Api.RateLimiting;
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, AllowMultiple = false, Inherited = true)]
public sealed class RedisRateLimitAttribute(string policy) : Attribute { public string Policy { get; } = policy; }
