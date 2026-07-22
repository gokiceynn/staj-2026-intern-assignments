using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Common.Abstractions;

public interface IJwtTokenService
{
    IssuedAccessToken CreateAccessToken(
        string accountId,
        string role,
        string sessionId,
        int securityVersion,
        DateTime utcNow);
}
