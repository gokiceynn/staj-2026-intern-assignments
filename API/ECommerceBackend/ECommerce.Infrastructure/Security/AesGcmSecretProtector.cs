using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
namespace ECommerce.Infrastructure.Security;
public sealed class AesGcmSecretProtector(IOptions<SecuritySecretsOptions> options)
{
    private readonly byte[] _key = Convert.FromBase64String(options.Value.EncryptionKeyBase64);
    public string Protect(string plaintext)
    {
        byte[] nonce = RandomNumberGenerator.GetBytes(12), data = Encoding.UTF8.GetBytes(plaintext), cipher = new byte[data.Length], tag = new byte[16];
        using AesGcm aes = new(_key, 16); aes.Encrypt(nonce, data, cipher, tag);
        byte[] output = new byte[nonce.Length + tag.Length + cipher.Length];
        Buffer.BlockCopy(nonce, 0, output, 0, nonce.Length); Buffer.BlockCopy(tag, 0, output, nonce.Length, tag.Length);
        Buffer.BlockCopy(cipher, 0, output, nonce.Length + tag.Length, cipher.Length);
        return Convert.ToBase64String(output);
    }
    public string Unprotect(string protectedValue)
    {
        byte[] input = Convert.FromBase64String(protectedValue), nonce = input[..12], tag = input[12..28], cipher = input[28..], plain = new byte[cipher.Length];
        using AesGcm aes = new(_key, 16); aes.Decrypt(nonce, cipher, tag, plain);
        return Encoding.UTF8.GetString(plain);
    }
}
