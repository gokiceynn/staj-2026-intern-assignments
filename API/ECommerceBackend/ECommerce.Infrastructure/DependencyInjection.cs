using ECommerce.Application.Common.Abstractions;
using ECommerce.Infrastructure.Admin;
using ECommerce.Infrastructure.Catalog;
using ECommerce.Infrastructure.Email;
using ECommerce.Infrastructure.Identifiers;
using ECommerce.Infrastructure.Orders;
using ECommerce.Infrastructure.Outbox;
using ECommerce.Infrastructure.Payments;
using ECommerce.Infrastructure.Persistence;
using ECommerce.Infrastructure.Persistence.Interceptors;
using ECommerce.Infrastructure.Persistence.Seed;
using ECommerce.Infrastructure.Persistence.Transactions;
using ECommerce.Infrastructure.Redis;
using ECommerce.Infrastructure.Security;
using ECommerce.Infrastructure.Shopping;
using ECommerce.Infrastructure.Storage;
using ECommerce.Infrastructure.Time;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using StackExchange.Redis;

namespace ECommerce.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOptions<JwtOptions>().Bind(configuration.GetSection(JwtOptions.SectionName)).ValidateDataAnnotations().ValidateOnStart();
        services.AddOptions<PasswordHashOptions>().Bind(configuration.GetSection(PasswordHashOptions.SectionName)).ValidateOnStart();
        services.AddOptions<SecuritySecretsOptions>().Bind(configuration.GetSection(SecuritySecretsOptions.SectionName)).Validate(x =>
            Convert.FromBase64String(x.HmacPepperBase64).Length >= 32 && Convert.FromBase64String(x.EncryptionKeyBase64).Length == 32).ValidateOnStart();
        services.AddOptions<RedisOptions>().Bind(configuration.GetSection(RedisOptions.SectionName)).Validate(x => !string.IsNullOrWhiteSpace(x.ConnectionString)).ValidateOnStart();
        services.AddOptions<OtpOptions>().Bind(configuration.GetSection(OtpOptions.SectionName)).ValidateOnStart();
        services.AddOptions<StorageOptions>().Bind(configuration.GetSection(StorageOptions.SectionName)).ValidateOnStart();
        services.AddOptions<SmtpOptions>().Bind(configuration.GetSection(SmtpOptions.SectionName)).ValidateOnStart();
        services.AddOptions<AdminSeedOptions>().Bind(configuration.GetSection(AdminSeedOptions.SectionName)).ValidateOnStart();

        string mySql = configuration.GetConnectionString("MySql") ?? throw new InvalidOperationException("MySql connection string is missing.");
        services.AddScoped<EntityAuditInterceptor>();
        services.AddDbContext<AppDbContext>((sp, options) => options
            .UseMySql(mySql, ServerVersion.Parse("8.4.0-mysql"), mysql =>
                mysql.EnableRetryOnFailure(5, TimeSpan.FromSeconds(10), null)
                     .MigrationsAssembly(typeof(AppDbContext).Assembly.FullName))
            .UseSnakeCaseNamingConvention()
            .AddInterceptors(sp.GetRequiredService<EntityAuditInterceptor>())
            .EnableDetailedErrors());
        services.AddScoped<IAppDbContext>(sp => sp.GetRequiredService<AppDbContext>());
        services.AddScoped<ITransactionRunner, EfTransactionRunner>();
        services.AddScoped<DatabaseSeeder>();

        ConfigurationOptions redisConfig = ConfigurationOptions.Parse(configuration["Redis:ConnectionString"]!, true);
        redisConfig.AbortOnConnectFail = false; redisConfig.ConnectRetry = 3; redisConfig.ReconnectRetryPolicy = new ExponentialRetry(1000);
        services.AddSingleton<IConnectionMultiplexer>(_ => ConnectionMultiplexer.Connect(redisConfig));
        services.AddSingleton<RedisKeyBuilder>();
        services.AddScoped<ISecurityRedisStore, SecurityRedisStore>();
        services.AddScoped<ICacheService, RedisCacheService>();
        services.AddScoped<IOtpService, OtpService>();
        services.AddScoped<ILoginAttemptLimiter, LoginAttemptLimiter>();

        services.AddSingleton<IClock, SystemClock>();
        services.AddSingleton<IIdGenerator, SortableIdGenerator>();
        services.AddSingleton<JwtKeyProvider>();
        services.AddSingleton<IPasswordHasher, Argon2PasswordHasher>();
        services.AddSingleton<IRefreshTokenService, RefreshTokenService>();
        services.AddSingleton<IJwtTokenService, JwtTokenService>();
        services.AddSingleton<AesGcmSecretProtector>();

        services.AddScoped<TokenRevocationCoordinator>();
        services.AddScoped<IAuthenticationSessionService, AuthenticationSessionService>();
        services.AddScoped<ITokenRevocationChecker, TokenRevocationChecker>();
        services.AddScoped<IAccountTokenRevocationService, AccountTokenRevocationService>();
        services.AddScoped<IAccountCredentialService, AccountCredentialService>();
        services.AddScoped<IOutboxWriter, OutboxWriter>();
        services.AddScoped<IOutboxMessageDispatcher, OutboxMessageDispatcher>();
        services.AddHostedService<OutboxProcessor>();

        services.AddScoped<IEmailSender, MailKitEmailSender>();
        services.AddScoped<IFileStorage, LocalFileStorage>();
        services.AddScoped<IPaymentGateway, SimulationPaymentGateway>();
        services.AddScoped<ICategoryHierarchyReader, CategoryHierarchyReader>();
        services.AddScoped<ICartService, CartService>();
        services.AddScoped<IReviewWriter, ReviewWriter>();
        services.AddScoped<ISellerProductService, SellerProductService>();
        services.AddScoped<IOrderService, OrderService>();
        services.AddScoped<ISellerOrderService, SellerOrderService>();
        services.AddScoped<IAdminQueryService, AdminQueryService>();
        services.AddScoped<IShippingCarrierAdminService, ShippingCarrierAdminService>();
        return services;
    }
}
