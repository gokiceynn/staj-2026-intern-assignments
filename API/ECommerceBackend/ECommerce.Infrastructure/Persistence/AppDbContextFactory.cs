using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace ECommerce.Infrastructure.Persistence;

public sealed class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        string connection = Environment.GetEnvironmentVariable("ConnectionStrings__MySql")
            ?? "Server=127.0.0.1;Port=3306;Database=ecommerce;User=ecommerce_app;Password=change-me";
        DbContextOptionsBuilder<AppDbContext> builder = new();
        builder.UseMySql(connection, ServerVersion.Parse("8.4.0-mysql"), x =>
            x.MigrationsAssembly(typeof(AppDbContext).Assembly.FullName));
        return new AppDbContext(builder.Options);
    }
}
