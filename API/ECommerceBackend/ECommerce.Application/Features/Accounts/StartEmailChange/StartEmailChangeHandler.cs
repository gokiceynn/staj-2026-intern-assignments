using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Accounts.StartEmailChange;

public sealed class StartEmailChangeHandler(
    IAppDbContext db, ICurrentUser currentUser, IPasswordHasher passwordHasher,
    IOtpService otpService, IValidator<StartEmailChangeCommand> validator)
{
    public async Task<Result<StartEmailChangeResult>> HandleAsync(StartEmailChangeCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result<StartEmailChangeResult>.Failure(error);
        var account = await db.Accounts.SingleOrDefaultAsync(x => x.Id == currentUser.AccountId && x.IsActive, ct);
        if (account is null || !passwordHasher.Verify(command.Password, account.PasswordHash))
            return Result<StartEmailChangeResult>.Failure(AuthErrors.InvalidCredentials);
        string normalized = command.NewEmail.Trim().ToUpperInvariant();
        if (normalized == account.NormalizedEmail || await db.Accounts.AnyAsync(x => x.NormalizedEmail == normalized, ct))
            return Result<StartEmailChangeResult>.Failure(AuthErrors.EmailAlreadyExists);

        Result<OtpStartResult> otp = await otpService.StartAsync(
            OtpPurpose.EmailChange, command.NewEmail.Trim(), account.Id, command.NewEmail.Trim(), ct);
        return otp.IsSuccess
            ? Result<StartEmailChangeResult>.Success(new(otp.Value!.SessionId, otp.Value.ExpiresAtUtc))
            : Result<StartEmailChangeResult>.Failure(otp.Error!);
    }
}
