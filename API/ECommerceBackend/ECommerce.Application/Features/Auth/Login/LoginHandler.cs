using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Auth.Login;

public sealed class LoginHandler(
    IAppDbContext db, IPasswordHasher passwordHasher, IAuthenticationSessionService sessions,
    ILoginAttemptLimiter attempts, ICurrentUser requestContext, IClock clock, IValidator<LoginCommand> validator)
{
    public async Task<Result<LoginResult>> HandleAsync(LoginCommand command, CancellationToken ct)
    {
        Error? validationError = await validator.ValidateAsErrorAsync(command, ct);
        if (validationError is not null) return Result<LoginResult>.Failure(validationError);

        string normalizedEmail = command.Email.Trim().ToUpperInvariant();
        if (!(await attempts.ConsumeAsync(normalizedEmail, ct)).IsAllowed)
            return Result<LoginResult>.Failure(AuthErrors.RateLimited);
        var account = await db.Accounts.Include(x => x.Role).SingleOrDefaultAsync(x => x.NormalizedEmail == normalizedEmail, ct);
        if (account is null || !account.IsActive) return Result<LoginResult>.Failure(AuthErrors.InvalidCredentials);
        if (account.LockoutEndUtc > clock.UtcNow) return Result<LoginResult>.Failure(AuthErrors.AccountLocked);

        if (!passwordHasher.Verify(command.Password, account.PasswordHash))
        {
            account.AccessFailedCount++;
            if (account.AccessFailedCount >= 5)
            {
                account.LockoutEndUtc = clock.UtcNow.AddMinutes(15);
                account.AccessFailedCount = 0;
            }
            await db.SaveChangesAsync(ct);
            return Result<LoginResult>.Failure(AuthErrors.InvalidCredentials);
        }

        if (!account.IsEmailVerified) return Result<LoginResult>.Failure(AuthErrors.EmailNotVerified);
        if (passwordHasher.NeedsRehash(account.PasswordHash)) account.PasswordHash = passwordHasher.Hash(command.Password);
        account.AccessFailedCount = 0;
        account.LockoutEndUtc = null;
        account.LastLoginAtUtc = clock.UtcNow;
        await db.SaveChangesAsync(ct);

        AuthenticatedAccount authenticated = await sessions.CreateAsync(account, requestContext.IpAddress, requestContext.UserAgent, ct);
        return Result<LoginResult>.Success(new(authenticated.Tokens.AccessToken, authenticated.Tokens.AccessTokenExpiresAtUtc,
            authenticated.Tokens.RefreshToken, authenticated.Tokens.RefreshTokenExpiresAtUtc, authenticated.Account));
    }
}
