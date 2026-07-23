using ECommerce.Application.Common.Security;
using ECommerce.Domain.Common;

namespace ECommerce.Api.Authorization;

public static class AuthorizationPolicies
{
    public static IServiceCollection AddApplicationAuthorization(
        this IServiceCollection services
    ) =>
        services.AddAuthorization(options =>
        {
            options.AddPolicy(
                PolicyNames.CustomerOnly,
                p => p.RequireAuthenticatedUser().RequireRole(RoleCodes.Customer)
            );
            options.AddPolicy(
                PolicyNames.SellerOnly,
                p => p.RequireAuthenticatedUser().RequireRole(RoleCodes.Seller)
            );
            options.AddPolicy(
                PolicyNames.AdminOnly,
                p => p.RequireAuthenticatedUser().RequireRole(RoleCodes.Admin)
            );
            options.AddPolicy(
                PolicyNames.CustomerOrAdmin,
                p => p.RequireAuthenticatedUser().RequireRole(RoleCodes.Customer, RoleCodes.Admin)
            );
            options.FallbackPolicy = null;
        });
}

