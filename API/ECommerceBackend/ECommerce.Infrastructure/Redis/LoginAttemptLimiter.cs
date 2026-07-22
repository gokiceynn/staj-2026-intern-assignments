using System.Security.Cryptography;
using System.Text;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Redis;
using ECommerce.Infrastructure.Security;
using Microsoft.Extensions.Options;
namespace ECommerce.Infrastructure.Redis;
public sealed class LoginAttemptLimiter(ISecurityRedisStore redis, IOptions<SecuritySecretsOptions> secrets) : ILoginAttemptLimiter
{
    private readonly byte[] _pepper = Convert.FromBase64String(secrets.Value.HmacPepperBase64);
    public Task<RateLimitDecision> ConsumeAsync(string normalizedEmail, CancellationToken ct)
    {
        using HMACSHA256 hmac = new(_pepper);
        string partition = Convert.ToHexString(hmac.ComputeHash(Encoding.UTF8.GetBytes(normalizedEmail))).ToLowerInvariant();
        return redis.TryConsumeRateLimitAsync(new RateLimitRule("login-email", 5, TimeSpan.FromMinutes(15)), partition, ct);
    }
}
