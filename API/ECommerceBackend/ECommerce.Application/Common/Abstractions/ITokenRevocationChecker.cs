namespace ECommerce.Application.Common.Abstractions;

public interface ITokenRevocationChecker
{
    Task<bool> IsTokenValidAsync(
        string accountId,
        string jti,
        string sessionId,
        int securityVersion,
        CancellationToken cancellationToken);
}
