using ECommerce.Application.Common.Redis;
using Microsoft.Extensions.Options;
namespace ECommerce.Infrastructure.Redis;
public sealed class RedisKeyBuilder(IOptions<RedisOptions> options)
{
    private readonly string _prefix = options.Value.InstancePrefix;
    public string Otp(OtpPurpose purpose, string sessionId) => $"{_prefix}auth:otp:{purpose}:{sessionId}";
    public string OtpActive(OtpPurpose purpose, string emailHash) => $"{_prefix}auth:otp-active:{purpose}:{emailHash}";
    public string OtpCooldown(OtpPurpose purpose, string emailHash) => $"{_prefix}auth:otp-cooldown:{purpose}:{emailHash}";
    public string Blacklist(string jti) => $"{_prefix}auth:jwt:blacklist:{jti}";
    public string RevokedSession(string sid) => $"{_prefix}auth:session:revoked:{sid}";
    public string SecurityVersion(string accountId) => $"{_prefix}auth:account:security-version:{accountId}";
    public string RevocationBlock(string accountId) => $"{_prefix}auth:account:revocation-block:{accountId}";
    public string RateLimit(string policy, string partition) => $"{_prefix}ratelimit:{policy}:{partition}";
}
