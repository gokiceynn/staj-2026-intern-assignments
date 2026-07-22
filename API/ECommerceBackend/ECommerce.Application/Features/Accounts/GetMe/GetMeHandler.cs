using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Accounts.GetMe;

public sealed class GetMeHandler(IAppDbContext db, ICurrentUser currentUser)
{
    public async Task<Result<GetMeResult>> HandleAsync(GetMeQuery query, CancellationToken ct)
    {
        AccountSummary? account = await db.Accounts.AsNoTracking()
            .Where(x => x.Id == currentUser.AccountId && x.IsActive)
            .Select(x => new AccountSummary(x.Id, x.Email, x.FirstName, x.LastName, x.PhoneNumber, x.Role.Code, x.CreatedAtUtc))
            .SingleOrDefaultAsync(ct);
        return account is null
            ? Result<GetMeResult>.Failure(CommonErrors.NotFound)
            : Result<GetMeResult>.Success(new(account));
    }
}
