using System.Security.Claims;
using System.Threading.RateLimiting;
using ECommerce.Api.Authentication;
using ECommerce.Api.Authorization;
using ECommerce.Api.Contracts.Common;
using ECommerce.Api.Extensions;
using ECommerce.Api.Health;
using ECommerce.Api.Middleware;
using ECommerce.Api.RateLimiting;
using ECommerce.Application;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;
using ECommerce.Infrastructure;
using ECommerce.Infrastructure.Persistence;
using ECommerce.Infrastructure.Persistence.Seed;
using ECommerce.Infrastructure.Security;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUser, HttpCurrentUser>();
builder.Services.AddScoped<CustomJwtBearerEvents>();

builder.Services.AddControllers().AddJsonOptions(x =>
{
    x.JsonSerializerOptions.PropertyNamingPolicy = new ApiJsonNamingPolicy();
    x.JsonSerializerOptions.DictionaryKeyPolicy = null;
});
builder.Services.AddProblemDetails();
builder.Services.AddApiOpenApi();
builder.Services.AddApplicationAuthorization();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();
builder.Services.AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
    .Configure<JwtKeyProvider, IOptions<JwtOptions>>((o, keys, jwt) =>
    {
        o.MapInboundClaims = false; o.EventsType = typeof(CustomJwtBearerEvents);
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true, IssuerSigningKeys = keys.ValidationKeys,
            ValidateIssuer = true, ValidIssuer = jwt.Value.Issuer,
            ValidateAudience = true, ValidAudience = jwt.Value.Audience,
            ValidateLifetime = true, RequireExpirationTime = true, RequireSignedTokens = true,
            ValidAlgorithms = [SecurityAlgorithms.RsaSha256], ClockSkew = TimeSpan.FromSeconds(30),
            NameClaimType = ClaimNames.Subject, RoleClaimType = ClaimNames.Role
        };
    });

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = 429;
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
        RateLimitPartition.GetFixedWindowLimiter(context.Connection.RemoteIpAddress?.ToString() ?? "unknown", _ =>
            new FixedWindowRateLimiterOptions { PermitLimit = 120, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});
builder.Services.AddCors(x => x.AddPolicy("frontend", p => p
    .WithOrigins(builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? [])
    .AllowAnyHeader().AllowAnyMethod().WithExposedHeaders("X-Correlation-Id", "Retry-After", "RateLimit-Remaining", "RateLimit-Reset")));
builder.Services.Configure<ForwardedHeadersOptions>(x =>
{
    x.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    x.ForwardLimit = 1;
});
builder.Services.AddHealthChecks().AddDbContextCheck<AppDbContext>("mysql", tags: ["ready"]).AddCheck<RedisHealthCheck>("redis", tags: ["ready"]);
builder.Services.AddOpenTelemetry().ConfigureResource(x => x.AddService("ecommerce-api"))
    .WithTracing(x => x.AddAspNetCoreInstrumentation().AddHttpClientInstrumentation().AddOtlpExporter())
    .WithMetrics(x => x.AddAspNetCoreInstrumentation().AddRuntimeInstrumentation().AddOtlpExporter());

WebApplication app = builder.Build();
app.UseForwardedHeaders();
app.UseMiddleware<CorrelationIdMiddleware>();
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseRateLimiter();
app.UseRouting();
app.UseCors("frontend");
app.UseAuthentication();
app.UseMiddleware<RedisRateLimitMiddleware>();
app.UseAuthorization();
if (app.Environment.IsDevelopment()) { app.UseSwagger(); app.UseSwaggerUI(); }
app.MapHealthChecks("/health/live", new() { Predicate = _ => false });
app.MapHealthChecks("/health/ready", new() { Predicate = x => x.Tags.Contains("ready") });
app.MapControllers();

// Yalnızca Development: şema uygulanır, ardından istenirse örnek veri basılır.
// Production'da migration başlangıçta çalışmaz; orada migration bundle kullanılır.
if (app.Environment.IsDevelopment())
{
    using IServiceScope scope = app.Services.CreateScope();
    await scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.MigrateAsync();
    if (app.Configuration.GetValue<bool>("SeedOnStartup"))
        await scope.ServiceProvider.GetRequiredService<DatabaseSeeder>().SeedAsync(CancellationToken.None);
}
await app.RunAsync();
public partial class Program;
