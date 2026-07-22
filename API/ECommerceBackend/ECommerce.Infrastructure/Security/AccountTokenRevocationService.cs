using ECommerce.Application.Common.Abstractions;
namespace ECommerce.Infrastructure.Security;
public sealed class AccountTokenRevocationService(TokenRevocationCoordinator coordinator) : IAccountTokenRevocationService
{
    public Task RevokeAllForRefreshTokenReuseAsync(string accountId, string reusedRefreshSessionId, string ipAddress, CancellationToken ct) =>
        coordinator.RevokeAllAsync(accountId, $"refresh-token-reuse:{reusedRefreshSessionId}", ipAddress, ct);
    public Task RevokeAllForCredentialChangeAsync(string accountId, string reason, string ipAddress, CancellationToken ct) =>
        coordinator.RevokeAllAsync(accountId, reason, ipAddress, ct);
}
