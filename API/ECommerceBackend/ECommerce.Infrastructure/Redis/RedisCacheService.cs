using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using StackExchange.Redis;
namespace ECommerce.Infrastructure.Redis;
public sealed class RedisCacheService(IConnectionMultiplexer connection) : ICacheService
{
    private readonly IDatabase _db = connection.GetDatabase();
    public async Task<T?> GetAsync<T>(string key, CancellationToken ct)
    { RedisValue value = await _db.StringGetAsync(key).WaitAsync(ct); return value.IsNull ? default : JsonSerializer.Deserialize<T>((string)value!); }
    public async Task SetAsync<T>(string key, T value, TimeSpan ttl, CancellationToken ct) =>
        _ = await _db.StringSetAsync(key, JsonSerializer.Serialize(value), ttl).WaitAsync(ct);
    public async Task RemoveAsync(string key, CancellationToken ct) => _ = await _db.KeyDeleteAsync(key).WaitAsync(ct);
}
