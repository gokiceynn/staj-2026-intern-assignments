namespace ECommerce.Application.Common.Abstractions;

public interface IAccountTokenRevocationService
{
    Task RevokeAllForRefreshTokenReuseAsync(
        string accountId,
        string reusedRefreshSessionId,
        string ipAddress,
        CancellationToken cancellationToken
    );
    Task RevokeAllForCredentialChangeAsync(
        string accountId,
        string reason,
        string ipAddress,
        CancellationToken cancellationToken
    );
}

