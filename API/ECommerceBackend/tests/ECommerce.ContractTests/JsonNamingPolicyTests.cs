using ECommerce.Api.Contracts.Common;
using Xunit;
namespace ECommerce.ContractTests;
public sealed class JsonNamingPolicyTests
{
    [Theory]
    [InlineData("CreatedAtUtc", "createdAt")]
    [InlineData("AccessTokenExpiresAtUtc", "accessTokenExpiresAt")]
    [InlineData("OrderId", "orderId")]
public void NamingPolicy_MatchesContract(string input, string expected) => Assert.Equal(expected, new ApiJsonNamingPolicy().ConvertName(input));
}
