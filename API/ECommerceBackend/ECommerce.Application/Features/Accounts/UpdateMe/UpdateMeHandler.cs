using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Accounts.UpdateMe;

public sealed class UpdateMeHandler(IAppDbContext db, ICurrentUser currentUser, IClock clock, IValidator<UpdateMeCommand> validator)
{
    public async Task<Result<UpdateMeResult>> HandleAsync(UpdateMeCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result<UpdateMeResult>.Failure(error);
        var account = await db.Accounts.Include(x => x.Role).SingleOrDefaultAsync(x => x.Id == currentUser.AccountId && x.IsActive, ct);
        if (account is null) return Result<UpdateMeResult>.Failure(CommonErrors.NotFound);
        account.FirstName = command.FirstName.Trim();
        account.LastName = command.LastName.Trim();
        account.PhoneNumber = command.PhoneNumber.Trim();
        account.UpdatedAtUtc = clock.UtcNow;
        await db.SaveChangesAsync(ct);
        AccountSummary dto = new(account.Id, account.Email, account.FirstName, account.LastName, account.PhoneNumber, account.Role.Code, account.CreatedAtUtc);
        return Result<UpdateMeResult>.Success(new(dto));
    }
}
