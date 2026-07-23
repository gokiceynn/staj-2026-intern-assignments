namespace ECommerce.Application.Common.Abstractions;

public interface IPasswordHasher
{
    string Hash(string password);
    bool Verify(string password, string encodedHash);
    bool NeedsRehash(string encodedHash);
}
