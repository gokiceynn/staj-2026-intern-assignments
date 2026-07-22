# EF Core migrations

Bu klasördeki `*.cs`, `*.Designer.cs` ve `AppDbContextModelSnapshot.cs` dosyaları elle yazılmaz.

İlk migration:

```bash
dotnet ef migrations add InitialCreate --project ECommerce.Infrastructure --startup-project ECommerce.Api --output-dir Persistence/Migrations
```

SQL inceleme:

```bash
dotnet ef migrations script 0 InitialCreate --idempotent --project ECommerce.Infrastructure --startup-project ECommerce.Api --output artifacts/migrations/initial.sql
```

Production bundle:

```bash
dotnet ef migrations bundle --self-contained --target-runtime linux-x64 --project ECommerce.Infrastructure --startup-project ECommerce.Api --output artifacts/efbundle
```

Migration CI testi boş MySQL 8.4 veritabanına `0 -> latest -> 0 -> latest` uygular; tablo engine, collation, FK, unique index ve check constraint’leri doğrular.
