using ECommerce.Application.Common.Abstractions;
using ECommerce.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace ECommerce.IntegrationTests.Security;
public sealed class RedisOutageFallbackTests(ApiFactory factory) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task TokenChecker_UsesMySqlWhenRedisIsUnavailable()
    {
        var user = await TestUserFactory.CreateAsync(factory);
        using IServiceScope scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ECommerce.Infrastructure.Persistence.AppDbContext>();
        var token = db.AccessTokenRecords.Single(x => x.AccountId == user.AccountId);
        await factory.StopRedisAsync();
        try
        {
            bool valid = await scope.ServiceProvider.GetRequiredService<ITokenRevocationChecker>()
                .IsTokenValidAsync(user.AccountId, token.Jti, token.RefreshSessionId, token.AccountSecurityVersion, default);
            Assert.True(valid);
        }
        finally { await factory.StartRedisAsync(); }
    }
}
