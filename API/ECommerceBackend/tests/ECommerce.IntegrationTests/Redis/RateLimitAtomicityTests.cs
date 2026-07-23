using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Redis;
using ECommerce.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace ECommerce.IntegrationTests.Redis;
public sealed class RateLimitAtomicityTests(ApiFactory factory) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task ParallelRequests_NeverExceedPermitLimit()
    {
        using IServiceScope scope = factory.Services.CreateScope();
        ISecurityRedisStore store = scope.ServiceProvider.GetRequiredService<ISecurityRedisStore>();
        RateLimitRule rule = new("atomic-test", 10, TimeSpan.FromMinutes(1)); string partition = Guid.NewGuid().ToString("N");
        var decisions = await Task.WhenAll(Enumerable.Range(0, 100).Select(_ => store.TryConsumeRateLimitAsync(rule, partition, default)));
        Assert.Equal(10, decisions.Count(x => x.IsAllowed));
        Assert.All(decisions.Where(x => !x.IsAllowed), x => Assert.True(x.RetryAfterSeconds > 0));
    }
}
