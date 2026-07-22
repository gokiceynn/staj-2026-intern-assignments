using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Redis;
using StackExchange.Redis;

namespace ECommerce.Infrastructure.Redis;

public sealed class SecurityRedisStore(IConnectionMultiplexer connection, RedisKeyBuilder keys, IClock clock) : ISecurityRedisStore
{
    private readonly IDatabase _db = connection.GetDatabase();
    private static readonly string CreateOtpScript = Load("create-otp.lua");
    private static readonly string VerifyOtpScript = Load("verify-otp.lua");
    private static readonly string RateLimitScript = Load("increment-rate-limit.lua");
    private static readonly string BeginRevocationScript = Load("begin-account-revocation.lua");
    private static readonly string CompleteRevocationScript = Load("complete-account-revocation.lua");
    private static readonly string ValidateTokenScript = Load("validate-token-state.lua");

    public async Task<OtpCreateResult> CreateOtpSessionAsync(OtpSessionRecord session, TimeSpan ttl, TimeSpan cooldown, CancellationToken ct)
    {
        RedisKey sessionKey = keys.Otp(session.Purpose, session.SessionId);
        RedisResult raw = await _db.ScriptEvaluateAsync(CreateOtpScript,
            [keys.OtpActive(session.Purpose, session.EmailHash), keys.OtpCooldown(session.Purpose, session.EmailHash), sessionKey],
            [Ms(ttl), Ms(cooldown), session.AccountId ?? string.Empty, session.EmailHash, session.OtpHash,
             session.MaxAttempts, session.ProtectedPayload ?? string.Empty]).WaitAsync(ct);
        RedisResult[] result = (RedisResult[])raw!;
        return new((long)result[0] == 1, (int)Math.Ceiling((long)result[1] / 1000d));
    }

    public async Task<OtpVerificationResult> VerifyOtpAsync(OtpPurpose purpose, string sessionId, string otpHash, CancellationToken ct)
    {
        RedisResult raw = await _db.ScriptEvaluateAsync(VerifyOtpScript, [keys.Otp(purpose, sessionId)], [otpHash]).WaitAsync(ct);
        RedisResult[] result = (RedisResult[])raw!;
        long status = (long)result[0];
        return new(status == 1, status == -1, (int)(long)result[1], EmptyToNull((string?)result[2]), EmptyToNull((string?)result[3]));
    }

    public async Task<OtpSessionSnapshot?> GetOtpSessionAsync(OtpPurpose purpose, string sessionId, CancellationToken ct)
    {
        RedisKey key = keys.Otp(purpose, sessionId);
        RedisValue[] values = await _db.HashGetAsync(key, ["accountId", "payload"]).WaitAsync(ct);
        if (values.All(x => x.IsNull)) return null;
        TimeSpan? ttl = await _db.KeyTimeToLiveAsync(key).WaitAsync(ct);
        return new(EmptyToNull(values[0]), EmptyToNull(values[1]), ttl ?? TimeSpan.Zero);
    }

    public Task BlacklistJtiAsync(string jti, TimeSpan ttl, CancellationToken ct) => SetIfPositiveAsync(keys.Blacklist(jti), "1", ttl, ct);
    public async Task<bool> IsJtiBlacklistedAsync(string jti, CancellationToken ct) => await _db.KeyExistsAsync(keys.Blacklist(jti)).WaitAsync(ct);
    public Task RevokeSessionAsync(string sessionId, TimeSpan ttl, CancellationToken ct) => SetIfPositiveAsync(keys.RevokedSession(sessionId), "1", ttl, ct);

    public async Task SetSecurityVersionAsync(string accountId, int version, TimeSpan ttl, CancellationToken ct) =>
        _ = await _db.StringSetAsync(keys.SecurityVersion(accountId), version, ttl).WaitAsync(ct);

    public async Task BeginAccountRevocationAsync(string accountId, TimeSpan ttl, CancellationToken ct) =>
        _ = await _db.ScriptEvaluateAsync(BeginRevocationScript, [keys.RevocationBlock(accountId)], [Ms(ttl)]).WaitAsync(ct);

    public async Task CompleteAccountRevocationAsync(string accountId, int securityVersion,
        IReadOnlyCollection<BlacklistEntry> tokens, IReadOnlyCollection<RevokedSessionEntry> sessions, CancellationToken ct)
    {
        List<RedisKey> redisKeys = [keys.RevocationBlock(accountId), keys.SecurityVersion(accountId)];
        List<RedisValue> args = [securityVersion, Ms(TimeSpan.FromDays(15)), tokens.Count + sessions.Count];
        foreach (BlacklistEntry token in tokens)
        {
            redisKeys.Add(keys.Blacklist(token.Jti)); args.Add("jti"); args.Add(Ms(token.ExpiresAtUtc - clock.UtcNow));
        }
        foreach (RevokedSessionEntry session in sessions)
        {
            redisKeys.Add(keys.RevokedSession(session.SessionId)); args.Add("sid"); args.Add(Ms(session.ExpiresAtUtc - clock.UtcNow));
        }
        _ = await _db.ScriptEvaluateAsync(CompleteRevocationScript, [.. redisKeys], [.. args]).WaitAsync(ct);
    }

    public async Task<TokenStateResult> ValidateTokenStateAsync(string accountId, string jti, string sessionId, int securityVersion, CancellationToken ct)
    {
        RedisResult raw = await _db.ScriptEvaluateAsync(ValidateTokenScript,
            [keys.RevocationBlock(accountId), keys.Blacklist(jti), keys.RevokedSession(sessionId), keys.SecurityVersion(accountId)],
            [securityVersion]).WaitAsync(ct);
        RedisResult[] result = (RedisResult[])raw!;
        return new((long)result[0] == 1, (string?)result[1]);
    }

    public async Task<RateLimitDecision> TryConsumeRateLimitAsync(RateLimitRule rule, string partition, CancellationToken ct)
    {
        RedisResult raw = await _db.ScriptEvaluateAsync(RateLimitScript, [keys.RateLimit(rule.Policy, partition)],
            [rule.PermitLimit, Ms(rule.Window), new DateTimeOffset(clock.UtcNow).ToUnixTimeSeconds()]).WaitAsync(ct);
        RedisResult[] result = (RedisResult[])raw!;
        return new((long)result[0] == 1, (int)(long)result[1], (int)(long)result[2], (long)result[3]);
    }

    private async Task SetIfPositiveAsync(RedisKey key, RedisValue value, TimeSpan ttl, CancellationToken ct)
    {
        if (ttl <= TimeSpan.Zero) return;
        _ = await _db.StringSetAsync(key, value, ttl).WaitAsync(ct);
    }

    private static long Ms(TimeSpan value) => Math.Max(1, (long)Math.Ceiling(value.TotalMilliseconds));
    private static string? EmptyToNull(RedisValue value) => value.IsNullOrEmpty ? null : value.ToString();
    private static string Load(string name) => File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "Redis", "Scripts", name));
}
