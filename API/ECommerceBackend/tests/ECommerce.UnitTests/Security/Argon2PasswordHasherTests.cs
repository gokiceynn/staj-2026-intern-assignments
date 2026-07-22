using ECommerce.Infrastructure.Security;
using Microsoft.Extensions.Options;
using Xunit;
namespace ECommerce.UnitTests.Security;
public sealed class Argon2PasswordHasherTests
{
    private readonly Argon2PasswordHasher _sut = new(Options.Create(new PasswordHashOptions
        { MemorySizeKb = 8192, Iterations = 1, DegreeOfParallelism = 1, SaltSizeBytes = 16, HashSizeBytes = 32 }));
    [Fact] public void Hash_ThenVerify_Succeeds()
    { string hash = _sut.Hash("SecurePassword123"); Assert.True(_sut.Verify("SecurePassword123", hash)); Assert.False(_sut.Verify("wrong", hash)); }
    [Fact] public void SamePassword_UsesDifferentSalt()
    { Assert.NotEqual(_sut.Hash("SecurePassword123"), _sut.Hash("SecurePassword123")); }
    [Fact] public void MalformedHash_FailsWithoutThrowing()
    { Assert.False(_sut.Verify("password", "not-a-hash")); Assert.True(_sut.NeedsRehash("not-a-hash")); }
}
