using System.Net;
using System.Net.Http.Headers;
using ECommerce.Infrastructure.Security;
using ECommerce.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace ECommerce.IntegrationTests.Security;
public sealed class BlacklistAuthenticationTests(ApiFactory factory) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task AuthorizeEndpoint_RejectsTokenAfterAccountWideRevocation()
    {
        var user = await TestUserFactory.CreateAsync(factory);
        using (IServiceScope scope = factory.Services.CreateScope())
            await scope.ServiceProvider.GetRequiredService<TokenRevocationCoordinator>().RevokeAllAsync(user.AccountId, "test", "127.0.0.1", default);
        HttpClient client = factory.CreateClient(); client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", user.Tokens.AccessToken);
        HttpResponseMessage response = await client.GetAsync("/api/v1/account/me");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        Assert.Contains("UNAUTHORIZED", await response.Content.ReadAsStringAsync(), StringComparison.Ordinal);
    }
}
