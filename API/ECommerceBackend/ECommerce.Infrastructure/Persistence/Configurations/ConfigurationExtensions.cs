using ECommerce.Domain.Common;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ECommerce.Infrastructure.Persistence.Configurations;

internal static class ConfigurationExtensions
{
    public static void ConfigureEntityBase<T>(this EntityTypeBuilder<T> builder) where T : EntityBase
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnType("varchar(40)").HasMaxLength(40);
        builder.Property(x => x.CreatedAtUtc).HasColumnType("datetime(6)");
        builder.Property(x => x.UpdatedAtUtc).HasColumnType("datetime(6)");
        builder.Property(x => x.Version).HasColumnType("bigint").IsConcurrencyToken();
    }
}
