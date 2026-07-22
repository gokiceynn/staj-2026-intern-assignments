using Microsoft.OpenApi.Models;

namespace ECommerce.Api.Extensions;

public static class OpenApiExtensions
{
    public static IServiceCollection AddApiOpenApi(this IServiceCollection services)
    {
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(x =>
        {
            x.SwaggerDoc("v1", new OpenApiInfo { Title = "ECommerce API", Version = "v1" });
            x.AddSecurityDefinition(
                "Bearer",
                new OpenApiSecurityScheme
                {
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer",
                    BearerFormat = "JWT",
                }
            );
            x.AddSecurityRequirement(
                new OpenApiSecurityRequirement
                {
                    [
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer",
                            },
                        }
                    ] = [],
                }
            );
        });
        return services;
    }
}

