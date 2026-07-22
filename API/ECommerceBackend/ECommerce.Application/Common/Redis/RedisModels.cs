namespace ECommerce.Application.Common.Redis;

public sealed record OtpSessionRecord(
    string SessionId,
    OtpPurpose Purpose,
    string? AccountId,
    string EmailHash,
    string OtpHash,
    int MaxAttempts,
    string? ProtectedPayload,
    DateTime CreatedAtUtc,
    DateTime ExpiresAtUtc);

public sealed record OtpCreateResult(bool Created, int RetryAfterSeconds);
public sealed record OtpVerificationResult(bool IsValid, bool IsLocked, int AttemptsRemaining, string? AccountId, string? ProtectedPayload);
public sealed record OtpResendContext(string? AccountId, string Destination, string? ProtectedPayload);
public sealed record OtpSessionSnapshot(string? AccountId, string? ProtectedPayload, TimeSpan RemainingTtl);
public sealed record BlacklistEntry(string Jti, DateTime ExpiresAtUtc);
public sealed record RevokedSessionEntry(string SessionId, DateTime ExpiresAtUtc);
public sealed record TokenStateResult(bool IsValid, string? RejectionCode);
public sealed record RateLimitRule(string Policy, int PermitLimit, TimeSpan Window);
public sealed record RateLimitDecision(bool IsAllowed, int Remaining, int RetryAfterSeconds, long ResetUnixSeconds);
