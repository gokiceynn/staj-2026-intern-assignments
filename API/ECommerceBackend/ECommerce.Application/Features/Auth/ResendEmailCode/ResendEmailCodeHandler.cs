using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Common;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Auth.ResendEmailCode;

public sealed class ResendEmailCodeHandler(
    IAppDbContext db, IOtpService otpService, IValidator<ResendEmailCodeCommand> validator)
{
    public async Task<Result<ResendEmailCodeResult>> HandleAsync(ResendEmailCodeCommand command, CancellationToken ct)
    {
        Error? validationError = await validator.ValidateAsErrorAsync(command, ct);
        if (validationError is not null) return Result<ResendEmailCodeResult>.Failure(validationError);
        string normalized = command.Email.Trim().ToUpperInvariant();
        var account = await db.Accounts.Include(x => x.Role).SingleOrDefaultAsync(x => x.NormalizedEmail == normalized, ct);
        if (account is null || account.IsEmailVerified || !account.IsActive)
            return Result<ResendEmailCodeResult>.Failure(AuthErrors.InvalidCredentials);

        OtpPurpose purpose = account.Role.Code == RoleCodes.Seller
            ? OtpPurpose.SellerRegistration
            : OtpPurpose.CustomerRegistration;
        Result<OtpStartResult> otp = await otpService.StartAsync(purpose, account.Email, account.Id, null, ct);
        return otp.IsSuccess
            ? Result<ResendEmailCodeResult>.Success(new(otp.Value!.SessionId, otp.Value.ExpiresAtUtc))
            : Result<ResendEmailCodeResult>.Failure(otp.Error!);
    }
}
