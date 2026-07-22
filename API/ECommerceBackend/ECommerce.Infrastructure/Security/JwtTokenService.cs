using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Security;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace ECommerce.Infrastructure.Security;

public sealed class JwtTokenService(JwtKeyProvider keys, IOptions<JwtOptions> options, IIdGenerator ids) : IJwtTokenService
{
    private readonly JwtOptions _options = options.Value;

    public IssuedAccessToken CreateAccessToken(string accountId, string role, string sessionId, int securityVersion, DateTime utcNow)
    {
        string jti = ids.NewId("jti");
        DateTime expires = utcNow.AddMinutes(_options.AccessTokenMinutes);
        Claim[] claims =
        [
            new(ClaimNames.Subject, accountId), new(ClaimNames.JwtId, jti), new(ClaimNames.SessionId, sessionId),
            new(ClaimNames.Role, role), new(ClaimNames.SecurityVersion, securityVersion.ToString(System.Globalization.CultureInfo.InvariantCulture))
        ];
        JwtSecurityToken token = new(_options.Issuer, _options.Audience, claims, utcNow.AddSeconds(-5), expires, keys.SigningCredentials);
        return new(new JwtSecurityTokenHandler().WriteToken(token), jti, utcNow, expires);
    }
}
