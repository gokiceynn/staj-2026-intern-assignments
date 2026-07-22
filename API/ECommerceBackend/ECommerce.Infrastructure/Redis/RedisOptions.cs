namespace ECommerce.Infrastructure.Redis;
public sealed class RedisOptions
{
    public const string SectionName = "Redis";
    public string ConnectionString { get; init; } = string.Empty;
    public string InstancePrefix { get; init; } = "ecommerce:v1:";
    public int OperationTimeoutMilliseconds { get; init; } = 1000;
}
