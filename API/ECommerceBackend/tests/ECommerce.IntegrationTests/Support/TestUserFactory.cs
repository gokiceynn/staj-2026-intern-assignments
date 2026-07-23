using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Domain.Common;
using ECommerce.Domain.Identity;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
namespace ECommerce.IntegrationTests.Support;
public static class TestUserFactory
{
    public static async Task<(string AccountId, TokenPair Tokens)> CreateAsync(ApiFactory factory, string roleCode = RoleCodes.Customer)
    {
        using IServiceScope scope = factory.Services.CreateScope();
        AppDbContext db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        Role? role = await db.Roles.SingleOrDefaultAsync(x => x.Code == roleCode);
        if (role is null)
        {
            role = new Role { Id = "rol_" + roleCode.ToLowerInvariant(), Code = roleCode, DisplayName = roleCode, CreatedAtUtc = factory.Clock.UtcNow };
            db.Roles.Add(role); await db.SaveChangesAsync();
        }
        string id = "usr_" + Guid.NewGuid().ToString("N");
        var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();
        Account account = new() { Id = id, Email = id + "@example.com", NormalizedEmail = (id + "@example.com").ToUpperInvariant(),
            PasswordHash = hasher.Hash("SecurePassword123"), PasswordHashVersion = 1, FirstName = "Test", LastName = "User",
            PhoneNumber = "+905551112233", RoleId = role.Id, Role = role, IsEmailVerified = true, IsActive = true,
            SecurityVersion = 1, CreatedAtUtc = factory.Clock.UtcNow };
        db.Accounts.Add(account); await db.SaveChangesAsync();
        AuthenticatedAccount auth = await scope.ServiceProvider.GetRequiredService<IAuthenticationSessionService>()
            .CreateAsync(account, "127.0.0.1", "integration-test", CancellationToken.None);
        return (id, auth.Tokens);
    }
}
