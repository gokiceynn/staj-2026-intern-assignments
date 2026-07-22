using System.Security.Cryptography;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace ECommerce.Infrastructure.Security;

public sealed class JwtKeyProvider
{
    public JwtKeyProvider(IOptions<JwtOptions> options)
    {
        JwtOptions value = options.Value;
        RSA privateRsa = RSA.Create();
        privateRsa.ImportFromPem(File.ReadAllText(value.PrivateKeyPath));
        SigningCredentials = new(new RsaSecurityKey(privateRsa) { KeyId = value.CurrentKeyId }, SecurityAlgorithms.RsaSha256);

        List<SecurityKey> validationKeys = [];
        foreach (string path in Directory.EnumerateFiles(value.PublicKeysPath, "*.pem", SearchOption.TopDirectoryOnly))
        {
            RSA rsa = RSA.Create(); rsa.ImportFromPem(File.ReadAllText(path));
            validationKeys.Add(new RsaSecurityKey(rsa) { KeyId = Path.GetFileNameWithoutExtension(path) });
        }
        ValidationKeys = validationKeys;
    }

    public SigningCredentials SigningCredentials { get; }
    public IReadOnlyCollection<SecurityKey> ValidationKeys { get; }
}
