using System.Security.Cryptography;
using ECommerce.Application.Common.Abstractions;
using Microsoft.IdentityModel.Tokens;
namespace ECommerce.Infrastructure.Identifiers;
public sealed class SortableIdGenerator : IIdGenerator
{
    public string NewId(string prefix)
    {
        long milliseconds = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        Span<byte> bytes = stackalloc byte[16];
        System.Buffers.Binary.BinaryPrimitives.WriteInt64BigEndian(bytes[..8], milliseconds);
        RandomNumberGenerator.Fill(bytes[8..]);
        return $"{prefix}_{Base64UrlEncoder.Encode(bytes.ToArray())}";
    }
}
