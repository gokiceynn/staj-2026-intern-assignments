using ECommerce.Application.Common.Abstractions;
using ECommerce.Infrastructure.Persistence;
using ECommerce.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace ECommerce.IntegrationTests.Security;
public sealed class RefreshTokenReuseTests(ApiFactory factory) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task ReusingRotatedToken_RevokesEverySessionAndAccessToken()
    {
        var user = await TestUserFactory.CreateAsync(factory);
        factory.Clock.Advance(TimeSpan.FromMinutes(20));
        using (IServiceScope scope = factory.Services.CreateScope())
        {
            var sessions = scope.ServiceProvider.GetRequiredService<IAuthenticationSessionService>();
            var firstRotation = await sessions.RotateAsync(user.Tokens.RefreshToken, user.Tokens.AccessToken, "127.0.0.1", "test", default);
            Assert.True(firstRotation.IsSuccess);
        }
        using (IServiceScope scope = factory.Services.CreateScope())
        {
            var sessions = scope.ServiceProvider.GetRequiredService<IAuthenticationSessionService>();
            var reuse = await sessions.RotateAsync(user.Tokens.RefreshToken, user.Tokens.AccessToken, "127.0.0.1", "attacker", default);
            Assert.False(reuse.IsSuccess); Assert.Equal("REFRESH_TOKEN_REUSE", reuse.Error!.Code);
        }
        using (IServiceScope scope = factory.Services.CreateScope())
        {
            AppDbContext db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            Assert.All(await db.RefreshSessions.Where(x => x.AccountId == user.AccountId).ToListAsync(), x => Assert.NotNull(x.RevokedAtUtc));
            Assert.All(await db.AccessTokenRecords.Where(x => x.AccountId == user.AccountId).ToListAsync(), x => Assert.NotNull(x.RevokedAtUtc));
            Assert.Equal(2, await db.Accounts.Where(x => x.Id == user.AccountId).Select(x => x.SecurityVersion).SingleAsync());
            ISecurityRedisStore redis = scope.ServiceProvider.GetRequiredService<ISecurityRedisStore>();
            foreach (string jti in await db.AccessTokenRecords.Where(x => x.AccountId == user.AccountId && x.ExpiresAtUtc > factory.Clock.UtcNow).Select(x => x.Jti).ToListAsync())
                Assert.True(await redis.IsJtiBlacklistedAsync(jti, default));
        }
    }
}
