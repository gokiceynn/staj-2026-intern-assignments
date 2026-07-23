using ECommerce.Domain.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ECommerce.Infrastructure.Persistence.Configurations;

public sealed class RoleConfiguration : IEntityTypeConfiguration<Role>
{
    public void Configure(EntityTypeBuilder<Role> b)
    {
        b.ToTable("roles"); b.ConfigureEntityBase();
        b.Property(x => x.Code).HasColumnType("varchar(40)").HasMaxLength(40).IsRequired();
        b.Property(x => x.DisplayName).HasColumnType("varchar(100)").HasMaxLength(100).IsRequired();
        b.HasIndex(x => x.Code).IsUnique();
    }
}

public sealed class AccountConfiguration : IEntityTypeConfiguration<Account>
{
    public void Configure(EntityTypeBuilder<Account> b)
    {
        b.ToTable("accounts"); b.ConfigureEntityBase();
        b.Property(x => x.Email).HasColumnType("varchar(254)").HasMaxLength(254).IsRequired();
        b.Property(x => x.NormalizedEmail).HasColumnType("varchar(254)").HasMaxLength(254).UseCollation("ascii_bin").IsRequired();
        b.Property(x => x.PasswordHash).HasColumnType("varchar(512)").HasMaxLength(512).IsRequired();
        b.Property(x => x.FirstName).HasColumnType("varchar(100)").HasMaxLength(100).IsRequired();
        b.Property(x => x.LastName).HasColumnType("varchar(100)").HasMaxLength(100).IsRequired();
        b.Property(x => x.PhoneNumber).HasColumnType("varchar(20)").HasMaxLength(20).IsRequired();
        b.Property(x => x.RoleId).HasColumnType("varchar(40)").HasMaxLength(40).IsRequired();
        b.Property(x => x.LockoutEndUtc).HasColumnType("datetime(6)");
        b.Property(x => x.LastLoginAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.DeletedAtUtc).HasColumnType("datetime(6)");
        b.HasIndex(x => x.NormalizedEmail).IsUnique();
        b.HasIndex(x => new { x.RoleId, x.IsActive });
        b.HasOne(x => x.Role).WithMany(x => x.Accounts).HasForeignKey(x => x.RoleId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class RefreshSessionConfiguration : IEntityTypeConfiguration<RefreshSession>
{
    public void Configure(EntityTypeBuilder<RefreshSession> b)
    {
        b.ToTable("refresh_sessions"); b.ConfigureEntityBase();
        b.Property(x => x.AccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.TokenHash).HasColumnType("char(64)").HasMaxLength(64).UseCollation("ascii_bin");
        b.Property(x => x.TokenFamilyId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.ParentSessionId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.ReplacedBySessionId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.ExpiresAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.LastUsedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.RevokedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.ReuseDetectedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.RevocationReason).HasColumnType("varchar(120)").HasMaxLength(120);
        b.Property(x => x.CreatedByIp).HasColumnType("varchar(64)").HasMaxLength(64);
        b.Property(x => x.RevokedByIp).HasColumnType("varchar(64)").HasMaxLength(64);
        b.Property(x => x.UserAgentHash).HasColumnType("char(64)").HasMaxLength(64);
        b.HasIndex(x => x.TokenHash).IsUnique();
        b.HasIndex(x => new { x.AccountId, x.ExpiresAtUtc, x.RevokedAtUtc });
        b.HasIndex(x => x.TokenFamilyId);
        b.HasIndex(x => x.ParentSessionId);
        b.HasOne(x => x.Account).WithMany(x => x.RefreshSessions).HasForeignKey(x => x.AccountId).OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class AccessTokenRecordConfiguration : IEntityTypeConfiguration<AccessTokenRecord>
{
    public void Configure(EntityTypeBuilder<AccessTokenRecord> b)
    {
        b.ToTable("access_token_records"); b.ConfigureEntityBase();
        b.Property(x => x.Jti).HasColumnType("varchar(64)").HasMaxLength(64).UseCollation("ascii_bin");
        b.Property(x => x.AccountId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.RefreshSessionId).HasColumnType("varchar(40)").HasMaxLength(40);
        b.Property(x => x.IssuedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.ExpiresAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.RevokedAtUtc).HasColumnType("datetime(6)");
        b.Property(x => x.RevocationReason).HasColumnType("varchar(120)").HasMaxLength(120);
        b.Property(x => x.IssuedByIp).HasColumnType("varchar(64)").HasMaxLength(64);
        b.Property(x => x.UserAgentHash).HasColumnType("char(64)").HasMaxLength(64);
        b.HasIndex(x => x.Jti).IsUnique();
        b.HasIndex(x => new { x.AccountId, x.ExpiresAtUtc, x.RevokedAtUtc });
        b.HasIndex(x => x.RefreshSessionId);
        b.HasOne(x => x.Account).WithMany(x => x.AccessTokens).HasForeignKey(x => x.AccountId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(x => x.RefreshSession).WithMany(x => x.AccessTokens).HasForeignKey(x => x.RefreshSessionId).OnDelete(DeleteBehavior.Restrict);
    }
}
