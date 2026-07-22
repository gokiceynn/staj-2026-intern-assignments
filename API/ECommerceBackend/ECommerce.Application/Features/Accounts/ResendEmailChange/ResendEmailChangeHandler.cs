using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Accounts.ResendEmailChange;

public sealed class ResendEmailChangeHandler(
    IAppDbContext db, IOtpService otpService, IPasswordHasher passwordHasher,
    ICurrentUser currentUser, IValidator<ResendEmailChangeCommand> validator)
{
    public async Task<Result<ResendEmailChangeResult>> HandleAsync(ResendEmailChangeCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result<ResendEmailChangeResult>.Failure(error);
        var account = await db.Accounts.SingleAsync(x => x.Id == currentUser.AccountId && x.IsActive, ct);
        if (!passwordHasher.Verify(command.Password, account.PasswordHash))
            return Result<ResendEmailChangeResult>.Failure(AuthErrors.InvalidCredentials);
        OtpResendContext? current = await otpService.GetResendContextAsync(OtpPurpose.EmailChange, command.SessionId, ct);
        if (current?.AccountId != account.Id || string.IsNullOrWhiteSpace(current.ProtectedPayload))
            return Result<ResendEmailChangeResult>.Failure(AuthErrors.InvalidOtp);
        Result<OtpStartResult> next = await otpService.StartAsync(OtpPurpose.EmailChange, current.Destination, account.Id, current.ProtectedPayload, ct);
        return next.IsSuccess
            ? Result<ResendEmailChangeResult>.Success(new(next.Value!.SessionId, next.Value.ExpiresAtUtc))
            : Result<ResendEmailChangeResult>.Failure(next.Error!);
    }
}
