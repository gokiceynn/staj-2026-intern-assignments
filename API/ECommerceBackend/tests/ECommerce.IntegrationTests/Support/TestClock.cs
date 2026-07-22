using ECommerce.Application.Common.Abstractions;
namespace ECommerce.IntegrationTests.Support;
public sealed class TestClock(DateTime initial) : IClock
{
    public DateTime UtcNow { get; private set; } = initial;
    public void Advance(TimeSpan amount) => UtcNow = UtcNow.Add(amount);
}
