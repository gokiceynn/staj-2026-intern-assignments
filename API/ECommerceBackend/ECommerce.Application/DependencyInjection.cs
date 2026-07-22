using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace ECommerce.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly, includeInternalTypes: true);

        Type[] concreteTypes = typeof(DependencyInjection).Assembly.GetTypes()
            .Where(x => x is { IsAbstract: false, IsInterface: false } && x.Name.EndsWith("Handler", StringComparison.Ordinal))
            .ToArray();

        foreach (Type type in concreteTypes) services.AddScoped(type);
        return services;
    }
}
