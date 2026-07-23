using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Security;
namespace ECommerce.Api.RateLimiting;
public sealed record ApiRateLimitPolicy(RateLimitRule Rule, bool FailClosed);
public static class RateLimitPolicyRegistry
{
    public static readonly IReadOnlyDictionary<string, ApiRateLimitPolicy> All = new Dictionary<string, ApiRateLimitPolicy>
    {
        [RateLimitPolicyNames.Login] = new(new("login", 10, TimeSpan.FromMinutes(15)), true),
        [RateLimitPolicyNames.OtpVerify] = new(new("otp-verify", 20, TimeSpan.FromMinutes(5)), true),
        [RateLimitPolicyNames.OtpResend] = new(new("otp-resend", 3, TimeSpan.FromMinutes(10)), true),
        [RateLimitPolicyNames.ForgotPassword] = new(new("forgot-password", 3, TimeSpan.FromMinutes(15)), true),
        [RateLimitPolicyNames.Refresh] = new(new("refresh", 20, TimeSpan.FromMinutes(1)), true),
        [RateLimitPolicyNames.Upload] = new(new("upload", 20, TimeSpan.FromMinutes(10)), true),
        [RateLimitPolicyNames.Checkout] = new(new("checkout", 5, TimeSpan.FromMinutes(1)), true),
        [RateLimitPolicyNames.Mutation] = new(new("mutation", 60, TimeSpan.FromMinutes(1)), false)
    };
}
