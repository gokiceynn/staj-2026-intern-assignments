using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using ECommerce.Application.Common.Abstractions;
using Konscious.Security.Cryptography;
using Microsoft.Extensions.Options;

namespace ECommerce.Infrastructure.Security;

public sealed class Argon2PasswordHasher(IOptions<PasswordHashOptions> options) : IPasswordHasher
{
    private readonly PasswordHashOptions _options = options.Value;

    public string Hash(string password)
    {
        byte[] salt = RandomNumberGenerator.GetBytes(_options.SaltSizeBytes);
        byte[] hash = Derive(password, salt, _options.MemorySizeKb, _options.Iterations, _options.DegreeOfParallelism, _options.HashSizeBytes);
        return string.Create(CultureInfo.InvariantCulture,
            $"$argon2id$v=19$m={_options.MemorySizeKb},t={_options.Iterations},p={_options.DegreeOfParallelism}${Convert.ToBase64String(salt)}${Convert.ToBase64String(hash)}");
    }

    public bool Verify(string password, string encodedHash)
    {
        try
        {
            ParsedHash parsed = Parse(encodedHash);
            byte[] actual = Derive(password, parsed.Salt, parsed.Memory, parsed.Iterations, parsed.Parallelism, parsed.Hash.Length);
            return CryptographicOperations.FixedTimeEquals(actual, parsed.Hash);
        }
        catch (FormatException) { return false; }
    }

    public bool NeedsRehash(string encodedHash)
    {
        try
        {
            ParsedHash p = Parse(encodedHash);
            return p.Memory != _options.MemorySizeKb || p.Iterations != _options.Iterations ||
                   p.Parallelism != _options.DegreeOfParallelism || p.Hash.Length != _options.HashSizeBytes;
        }
        catch (FormatException) { return true; }
    }

    private static byte[] Derive(string password, byte[] salt, int memory, int iterations, int parallelism, int length)
    {
        using Argon2id argon = new(Encoding.UTF8.GetBytes(password))
        { Salt = salt, MemorySize = memory, Iterations = iterations, DegreeOfParallelism = parallelism };
        return argon.GetBytes(length);
    }

    private static ParsedHash Parse(string encoded)
    {
        string[] parts = encoded.Split('$', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length != 5 || parts[0] != "argon2id" || parts[1] != "v=19") throw new FormatException();
        Dictionary<string, int> parameters = parts[2].Split(',').Select(x => x.Split('=')).ToDictionary(x => x[0], x => int.Parse(x[1], CultureInfo.InvariantCulture));
        return new(parameters["m"], parameters["t"], parameters["p"], Convert.FromBase64String(parts[3]), Convert.FromBase64String(parts[4]));
    }

    private sealed record ParsedHash(int Memory, int Iterations, int Parallelism, byte[] Salt, byte[] Hash);
}
