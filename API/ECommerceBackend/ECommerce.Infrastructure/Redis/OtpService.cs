using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Infrastructure.Persistence;
using ECommerce.Infrastructure.Security;
using Microsoft.Extensions.Options;

namespace ECommerce.Infrastructure.Redis;

public sealed class OtpService(
    ISecurityRedisStore store, IOutboxWriter outbox, AppDbContext db, IIdGenerator ids, IClock clock,
    AesGcmSecretProtector protector, IOptions<OtpOptions> options, IOptions<SecuritySecretsOptions> secrets) : IOtpService
{
    private readonly OtpOptions _options = options.Value;
    private readonly byte[] _pepper = Convert.FromBase64String(secrets.Value.HmacPepperBase64);

    public async Task<Result<OtpStartResult>> StartAsync(
        OtpPurpose purpose, string email, string? accountId, string? protectedPayload, CancellationToken ct)
    {
        string sessionId = ids.NewId("sess");
        string code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6", System.Globalization.CultureInfo.InvariantCulture);
        DateTime now = clock.UtcNow, expires = now.AddMinutes(_options.LifetimeMinutes);
        string emailHash = Hmac(email.Trim().ToUpperInvariant());
        string envelope = protector.Protect(JsonSerializer.Serialize(new Envelope(email.Trim(), protectedPayload)));
        OtpSessionRecord record = new(sessionId, purpose, accountId, emailHash, Hmac($"{purpose}:{sessionId}:{code}"),
            _options.MaxAttempts, envelope, now, expires);
        OtpCreateResult created = await store.CreateOtpSessionAsync(record, expires - now,
            TimeSpan.FromSeconds(_options.ResendCooldownSeconds), ct);
        if (!created.Created) return Result<OtpStartResult>.Failure(AuthErrors.OtpCooldown);
        outbox.Add("SendOtpEmail", new { to = email.Trim(), code, purpose = purpose.ToString(), expiresAtUtc = expires });
        await db.SaveChangesAsync(ct);
        return Result<OtpStartResult>.Success(new(sessionId, expires));
    }

    public async Task<OtpVerificationResult> VerifyAsync(OtpPurpose purpose, string sessionId, string code, CancellationToken ct)
    {
        OtpVerificationResult result = await store.VerifyOtpAsync(purpose, sessionId, Hmac($"{purpose}:{sessionId}:{code}"), ct);
        return Decode(result);
    }

    public async Task<OtpVerificationResult> VerifyRegistrationAsync(string sessionId, string code, CancellationToken ct)
    {
        OtpVerificationResult customer = await VerifyAsync(OtpPurpose.CustomerRegistration, sessionId, code, ct);
        return customer.IsValid || customer.IsLocked || customer.AttemptsRemaining > 0
            ? customer
            : await VerifyAsync(OtpPurpose.SellerRegistration, sessionId, code, ct);
    }

    public async Task<OtpResendContext?> GetResendContextAsync(OtpPurpose purpose, string sessionId, CancellationToken ct)
    {
        OtpSessionSnapshot? snapshot = await store.GetOtpSessionAsync(purpose, sessionId, ct);
        if (snapshot?.ProtectedPayload is null) return null;
        Envelope envelope = JsonSerializer.Deserialize<Envelope>(protector.Unprotect(snapshot.ProtectedPayload))!;
        return new(snapshot.AccountId, envelope.Destination, envelope.Payload);
    }

    private OtpVerificationResult Decode(OtpVerificationResult result)
    {
        if (result.ProtectedPayload is null) return result;
        Envelope envelope = JsonSerializer.Deserialize<Envelope>(protector.Unprotect(result.ProtectedPayload))!;
        return result with { ProtectedPayload = envelope.Payload };
    }
    private string Hmac(string value)
    {
        using HMACSHA256 hmac = new(_pepper);
        return Convert.ToHexString(hmac.ComputeHash(Encoding.UTF8.GetBytes(value))).ToLowerInvariant();
    }
    private sealed record Envelope(string Destination, string? Payload);
}
