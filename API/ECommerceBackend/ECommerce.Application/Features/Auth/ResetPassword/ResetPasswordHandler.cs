using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Auth.ResetPassword;

public sealed class ResetPasswordHandler(
    IOtpService otpService, IAccountCredentialService credentials,
    ICurrentUser requestContext, IValidator<ResetPasswordCommand> validator)
{
    public async Task<Result> HandleAsync(ResetPasswordCommand command, CancellationToken ct)
    {
        Error? validationError = await validator.ValidateAsErrorAsync(command, ct);
        if (validationError is not null) return Result.Failure(validationError);
        OtpVerificationResult otp = await otpService.VerifyAsync(OtpPurpose.PasswordReset, command.SessionId, command.Code, ct);
        if (!otp.IsValid || otp.AccountId is null) return Result.Failure(AuthErrors.InvalidOtp);

        return await credentials.ResetPasswordAsync(otp.AccountId, command.NewPassword, requestContext.IpAddress, ct);
    }
}
