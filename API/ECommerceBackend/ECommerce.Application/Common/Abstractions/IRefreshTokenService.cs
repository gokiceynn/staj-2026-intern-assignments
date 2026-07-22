namespace ECommerce.Application.Common.Abstractions;

public interface IRefreshTokenService
{
    string GeneratePlainToken();
    string HashToken(string plainToken);
}
