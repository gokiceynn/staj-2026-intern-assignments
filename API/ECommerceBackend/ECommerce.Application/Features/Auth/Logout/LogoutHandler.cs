using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Features.Auth.Logout;

public sealed class LogoutHandler(ICurrentUser currentUser, IAuthenticationSessionService sessions)
{
    public async Task<Result> HandleAsync(LogoutCommand command, CancellationToken ct)
    {
        await sessions.LogoutAsync(currentUser.AccountId, currentUser.SessionId, currentUser.Jti, currentUser.IpAddress, ct);
        return Result.Success();
    }
}
