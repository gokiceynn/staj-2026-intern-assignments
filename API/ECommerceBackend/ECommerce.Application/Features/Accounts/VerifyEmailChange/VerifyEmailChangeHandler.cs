using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using FluentValidation;

namespace ECommerce.Application.Features.Accounts.VerifyEmailChange;

public sealed class VerifyEmailChangeHandler(
    IOtpService otpService, IAccountCredentialService credentials, ICurrentUser currentUser,
    IValidator<VerifyEmailChangeCommand> validator)
{
    public async Task<Result> HandleAsync(VerifyEmailChangeCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result.Failure(error);
        OtpVerificationResult otp = await otpService.VerifyAsync(OtpPurpose.EmailChange, command.SessionId, command.Code, ct);
        if (!otp.IsValid || otp.AccountId != currentUser.AccountId || string.IsNullOrWhiteSpace(otp.ProtectedPayload))
            return Result.Failure(AuthErrors.InvalidOtp);
        return await credentials.ChangeEmailAsync(currentUser.AccountId, otp.ProtectedPayload, currentUser.IpAddress, ct);
    }
}
