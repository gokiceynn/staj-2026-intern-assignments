using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;

namespace ECommerce.Application.Common.Abstractions;

public interface IOtpService
{
    Task<Result<OtpStartResult>> StartAsync(OtpPurpose purpose, string email, string? accountId, string? protectedPayload, CancellationToken ct);
    Task<OtpVerificationResult> VerifyAsync(OtpPurpose purpose, string sessionId, string code, CancellationToken ct);
    Task<OtpVerificationResult> VerifyRegistrationAsync(string sessionId, string code, CancellationToken ct);
    Task<OtpResendContext?> GetResendContextAsync(OtpPurpose purpose, string sessionId, CancellationToken ct);
}
