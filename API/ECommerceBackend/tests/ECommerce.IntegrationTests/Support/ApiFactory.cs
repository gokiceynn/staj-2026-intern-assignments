using System.Security.Cryptography;
using ECommerce.Infrastructure.Persistence;
using Microsoft.AspNetCore.TestHost;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Testcontainers.MySql;
using Testcontainers.Redis;
using Xunit;
namespace ECommerce.IntegrationTests.Support;
public sealed class ApiFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    private readonly MySqlContainer _mysql = new MySqlBuilder().WithImage("mysql:8.4").WithDatabase("ecommerce_test")
        .WithUsername("test").WithPassword("test-password").Build();
    private readonly RedisContainer _redis = new RedisBuilder().WithImage("redis:7.4-alpine").Build();
    private readonly string _keys = Path.Combine(Path.GetTempPath(), "ecommerce-tests", Guid.NewGuid().ToString("N"));
    public TestClock Clock { get; } = new(DateTime.UtcNow);
    public Task StopRedisAsync() => _redis.StopAsync();
    public Task StartRedisAsync() => _redis.StartAsync();

    public async Task InitializeAsync()
    {
        Directory.CreateDirectory(Path.Combine(_keys, "public"));
        using RSA rsa = RSA.Create(2048);
        await File.WriteAllTextAsync(Path.Combine(_keys, "private.pem"), rsa.ExportRSAPrivateKeyPem());
        await File.WriteAllTextAsync(Path.Combine(_keys, "public", "test-key.pem"), rsa.ExportRSAPublicKeyPem());
        await Task.WhenAll(_mysql.StartAsync(), _redis.StartAsync());
        using IServiceScope scope = Services.CreateScope();
        await scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.MigrateAsync();
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.ConfigureAppConfiguration((_, config) => config.AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["ConnectionStrings:MySql"] = _mysql.GetConnectionString(), ["Redis:ConnectionString"] = _redis.GetConnectionString(),
            ["Jwt:Issuer"] = "test-issuer", ["Jwt:Audience"] = "test-audience", ["Jwt:CurrentKeyId"] = "test-key",
            ["Jwt:PrivateKeyPath"] = Path.Combine(_keys, "private.pem"), ["Jwt:PublicKeysPath"] = Path.Combine(_keys, "public"),
            ["SecuritySecrets:HmacPepperBase64"] = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32)),
            ["SecuritySecrets:EncryptionKeyBase64"] = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32)),
            ["Smtp:Host"] = "localhost", ["Smtp:Port"] = "1025", ["Smtp:UseTls"] = "false", ["Smtp:FromAddress"] = "test@example.com",
            ["SeedOnStartup"] = "false"
        }));
        builder.ConfigureTestServices(services =>
        {
            Microsoft.Extensions.DependencyInjection.Extensions.ServiceCollectionDescriptorExtensions.RemoveAll<ECommerce.Application.Common.Abstractions.IClock>(services);
            Microsoft.Extensions.DependencyInjection.Extensions.ServiceCollectionDescriptorExtensions.RemoveAll<Microsoft.Extensions.Hosting.IHostedService>(services);
            services.AddSingleton<ECommerce.Application.Common.Abstractions.IClock>(Clock);
        });
    }

    async Task IAsyncLifetime.DisposeAsync()
    {
        await Task.WhenAll(_mysql.DisposeAsync().AsTask(), _redis.DisposeAsync().AsTask());
        if (Directory.Exists(_keys)) Directory.Delete(_keys, true);
        Dispose();
    }
}
