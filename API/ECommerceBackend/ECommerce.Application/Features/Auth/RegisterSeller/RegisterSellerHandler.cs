using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Redis;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Common;
using ECommerce.Domain.Identity;
using ECommerce.Domain.Profiles;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Auth.RegisterSeller;

public sealed class RegisterSellerHandler(
    IAppDbContext db, ITransactionRunner transactions, IPasswordHasher passwordHasher,
    IOtpService otpService, IIdGenerator ids, IClock clock, IValidator<RegisterSellerCommand> validator)
{
    public async Task<Result<RegisterSellerResult>> HandleAsync(RegisterSellerCommand command, CancellationToken ct)
    {
        Error? validationError = await validator.ValidateAsErrorAsync(command, ct);
        if (validationError is not null) return Result<RegisterSellerResult>.Failure(validationError);
        string normalizedEmail = command.Email.Trim().ToUpperInvariant();
        if (await db.Accounts.AnyAsync(x => x.NormalizedEmail == normalizedEmail, ct))
            return Result<RegisterSellerResult>.Failure(AuthErrors.EmailAlreadyExists);

        Role role = await db.Roles.SingleAsync(x => x.Code == RoleCodes.Seller, ct);
        Account account = new()
        {
            Id = ids.NewId("usr"), Email = command.Email.Trim(), NormalizedEmail = normalizedEmail,
            PasswordHash = passwordHasher.Hash(command.Password), PasswordHashVersion = 1,
            FirstName = command.FirstName.Trim(), LastName = command.LastName.Trim(), PhoneNumber = command.PhoneNumber.Trim(),
            RoleId = role.Id, CreatedAtUtc = clock.UtcNow, IsActive = true, SecurityVersion = 1
        };
        Result<OtpStartResult> otp = await otpService.StartAsync(OtpPurpose.SellerRegistration, account.Email, account.Id, null, ct);
        if (!otp.IsSuccess) return Result<RegisterSellerResult>.Failure(otp.Error!);

        return await transactions.ExecuteAsync(async token =>
        {
            db.Accounts.Add(account);
            db.SellerProfiles.Add(new SellerProfile
            {
                Id = ids.NewId("sel"), AccountId = account.Id, StoreName = command.StoreName.Trim(),
                TaxNumber = command.TaxNumber, TaxOffice = command.TaxOffice.Trim(), Description = string.Empty,
                IsActive = true, CreatedAtUtc = clock.UtcNow
            });
            await db.SaveChangesAsync(token);
            return Result<RegisterSellerResult>.Success(new(otp.Value!.SessionId, otp.Value.ExpiresAtUtc));
        }, System.Data.IsolationLevel.ReadCommitted, ct);
    }
}
