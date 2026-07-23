using ECommerce.Application.Common.Redis;

namespace ECommerce.Application.Common.Abstractions;

public interface ISecurityRedisStore
{
    Task<OtpCreateResult> CreateOtpSessionAsync(OtpSessionRecord session, TimeSpan ttl, TimeSpan cooldown, CancellationToken ct);
    Task<OtpVerificationResult> VerifyOtpAsync(OtpPurpose purpose, string sessionId, string otpHash, CancellationToken ct);
    Task<OtpSessionSnapshot?> GetOtpSessionAsync(OtpPurpose purpose, string sessionId, CancellationToken ct);
    Task BlacklistJtiAsync(string jti, TimeSpan ttl, CancellationToken ct);
    Task<bool> IsJtiBlacklistedAsync(string jti, CancellationToken ct);
    Task RevokeSessionAsync(string sessionId, TimeSpan ttl, CancellationToken ct);
    Task SetSecurityVersionAsync(string accountId, int version, TimeSpan ttl, CancellationToken ct);
    Task BeginAccountRevocationAsync(string accountId, TimeSpan ttl, CancellationToken ct);
    Task CompleteAccountRevocationAsync(string accountId, int securityVersion, IReadOnlyCollection<BlacklistEntry> tokens, IReadOnlyCollection<RevokedSessionEntry> sessions, CancellationToken ct);
    Task<TokenStateResult> ValidateTokenStateAsync(string accountId, string jti, string sessionId, int securityVersion, CancellationToken ct);
    Task<RateLimitDecision> TryConsumeRateLimitAsync(RateLimitRule rule, string partition, CancellationToken ct);
}
