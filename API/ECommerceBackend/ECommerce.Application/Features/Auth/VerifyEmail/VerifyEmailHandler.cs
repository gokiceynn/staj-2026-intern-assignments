using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Auth.VerifyEmail;

public sealed class VerifyEmailHandler(
    IAppDbContext db, IOtpService otpService, IAuthenticationSessionService sessions,
    ICurrentUser requestContext, IClock clock, IValidator<VerifyEmailCommand> validator)
{
    public async Task<Result<VerifyEmailResult>> HandleAsync(VerifyEmailCommand command, CancellationToken ct)
    {
        Error? validationError = await validator.ValidateAsErrorAsync(command, ct);
        if (validationError is not null) return Result<VerifyEmailResult>.Failure(validationError);

        OtpVerificationResult otp = await otpService.VerifyRegistrationAsync(command.SessionId, command.Code, ct);
        if (!otp.IsValid || otp.AccountId is null) return Result<VerifyEmailResult>.Failure(AuthErrors.InvalidOtp);

        var account = await db.Accounts.Include(x => x.Role).SingleOrDefaultAsync(x => x.Id == otp.AccountId, ct);
        if (account is null || !account.IsActive) return Result<VerifyEmailResult>.Failure(AuthErrors.InvalidOtp);
        account.IsEmailVerified = true;
        account.UpdatedAtUtc = clock.UtcNow;
        await db.SaveChangesAsync(ct);

        AuthenticatedAccount authenticated = await sessions.CreateAsync(account, requestContext.IpAddress, requestContext.UserAgent, ct);
        return Result<VerifyEmailResult>.Success(new(authenticated.Tokens.AccessToken, authenticated.Tokens.AccessTokenExpiresAtUtc,
            authenticated.Tokens.RefreshToken, authenticated.Tokens.RefreshTokenExpiresAtUtc, authenticated.Account));
    }
}
