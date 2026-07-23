using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Auth.ForgotPassword;

public sealed class ForgotPasswordHandler(
    IAppDbContext db, IOtpService otpService, IIdGenerator ids, IClock clock,
    IValidator<ForgotPasswordCommand> validator)
{
    public async Task<Result<ForgotPasswordResult>> HandleAsync(ForgotPasswordCommand command, CancellationToken ct)
    {
        Error? validationError = await validator.ValidateAsErrorAsync(command, ct);
        if (validationError is not null) return Result<ForgotPasswordResult>.Failure(validationError);
        string normalized = command.Email.Trim().ToUpperInvariant();
        var account = await db.Accounts.AsNoTracking().SingleOrDefaultAsync(x => x.NormalizedEmail == normalized && x.IsActive, ct);
        if (account is null)
            return Result<ForgotPasswordResult>.Success(new(ids.NewId("sess"), clock.UtcNow.AddMinutes(5)));

        Result<OtpStartResult> otp = await otpService.StartAsync(OtpPurpose.PasswordReset, account.Email, account.Id, null, ct);
        return otp.IsSuccess
            ? Result<ForgotPasswordResult>.Success(new(otp.Value!.SessionId, otp.Value.ExpiresAtUtc))
            : Result<ForgotPasswordResult>.Failure(otp.Error!);
    }
}
