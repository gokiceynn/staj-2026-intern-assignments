using System.Security.Cryptography;
using System.Text;
using ECommerce.Application.Common.Abstractions;
using Microsoft.IdentityModel.Tokens;

namespace ECommerce.Infrastructure.Security;

public sealed class RefreshTokenService : IRefreshTokenService
{
    public string GeneratePlainToken() => Base64UrlEncoder.Encode(RandomNumberGenerator.GetBytes(64));
    public string HashToken(string plainToken) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(plainToken))).ToLowerInvariant();
}
