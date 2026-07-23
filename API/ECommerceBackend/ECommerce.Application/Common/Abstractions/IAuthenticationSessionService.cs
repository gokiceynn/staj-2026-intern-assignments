using ECommerce.Application.Common.Models;
using ECommerce.Domain.Identity;

namespace ECommerce.Application.Common.Abstractions;

public interface IAuthenticationSessionService
{
    Task<AuthenticatedAccount> CreateAsync(Account account, string ipAddress, string userAgent, CancellationToken ct);
    Task<Result<TokenPair>> RotateAsync(string refreshToken, string expiredAccessToken, string ipAddress, string userAgent, CancellationToken ct);
    Task LogoutAsync(string accountId, string sessionId, string jti, string ipAddress, CancellationToken ct);
}
