using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Common;
using ECommerce.Domain.Identity;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Auth.RegisterCustomer;

public sealed class RegisterCustomerHandler(
    IAppDbContext db,
    IPasswordHasher passwordHasher,
    IOtpService otpService,
    IIdGenerator ids,
    IClock clock,
    IValidator<RegisterCustomerCommand> validator)
{
    public async Task<Result<RegisterCustomerResult>> HandleAsync(RegisterCustomerCommand command, CancellationToken ct)
    {
        Error? validationError = await validator.ValidateAsErrorAsync(command, ct);
        if (validationError is not null) return Result<RegisterCustomerResult>.Failure(validationError);

        string normalizedEmail = command.Email.Trim().ToUpperInvariant();
        if (await db.Accounts.AnyAsync(x => x.NormalizedEmail == normalizedEmail, ct))
            return Result<RegisterCustomerResult>.Failure(AuthErrors.EmailAlreadyExists);

        Role role = await db.Roles.SingleAsync(x => x.Code == RoleCodes.Customer, ct);
        Account account = new()
        {
            Id = ids.NewId("usr"),
            Email = command.Email.Trim(),
            NormalizedEmail = normalizedEmail,
            PasswordHash = passwordHasher.Hash(command.Password),
            PasswordHashVersion = 1,
            FirstName = command.FirstName.Trim(),
            LastName = command.LastName.Trim(),
            PhoneNumber = command.PhoneNumber.Trim(),
            RoleId = role.Id,
            CreatedAtUtc = clock.UtcNow,
            IsEmailVerified = false,
            IsActive = true,
            SecurityVersion = 1
        };

        Result<OtpStartResult> otp = await otpService.StartAsync(OtpPurpose.CustomerRegistration, account.Email, account.Id, null, ct);
        if (!otp.IsSuccess) return Result<RegisterCustomerResult>.Failure(otp.Error!);

        db.Accounts.Add(account);
        await db.SaveChangesAsync(ct);
        return Result<RegisterCustomerResult>.Success(new(otp.Value!.SessionId, otp.Value.ExpiresAtUtc));
    }
}
