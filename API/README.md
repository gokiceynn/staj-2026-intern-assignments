# ECommerce API

.NET 9, MySQL 8.4/InnoDB ve Redis tabanlı e-ticaret API'si.

## Yapı

```
API/
├── ECommerceBackend/   # çözüm kökü — .sln, global.json, Directory.*.props, .editorconfig
│   ├── ECommerce.Api / .Application / .Domain / .Infrastructure
│   └── tests/          # Unit, Architecture, Contract, Integration
└── docker/
    ├── Dockerfile      # API imajı (test ve prod ortak kullanır)
    ├── dev/            # konteyner içinde VS Code Server ile geliştirme
    ├── test/           # tüm stack'i ayağa kaldırma (api + mysql + redis + mailpit)
    └── prod/           # canlı: nginx + external secret'lar
```

`global.json`, `Directory.Build.props`, `Directory.Packages.props` ve `.editorconfig` `ECommerceBackend/` içindedir; **`dotnet` komutlarını o dizinden çalıştırın.**

## Docker ortamları

### dev — VS Code Server

Tarayıcıdan erişilen, .NET SDK'sı ve eklentileri hazır kurulmuş bir geliştirme konteyneri; yanında MySQL ve Redis ile gelir.

```bash
cd docker/dev
docker compose -f docker-compose.dev.yml up -d      # Windows: up.bat
```

| Servis | Adres |
|---|---|
| VS Code Server | http://127.0.0.1:8081 (parola: `123456`) |
| API (konteyner içinde `dotnet run`) | http://127.0.0.1:5081 |
| MySQL | 127.0.0.1:3307 |
| Redis | 127.0.0.1:6380 |

### test — uygulamayı ayağa kaldırma

API imajını build eder ve bağımlılıklarıyla birlikte çalıştırır.

```bash
cd docker/test
cp .env.example .env          # değerleri doldurun (aşağıdaki hazırlık adımlarına bakın)
docker compose up -d --build
```

| Servis | Adres |
|---|---|
| API | http://127.0.0.1:5082 (Swagger: `/swagger`) |
| Mailpit | http://127.0.0.1:8026 |
| MySQL | 127.0.0.1:3308 |
| Redis | 127.0.0.1:6381 |

Portlar dev stack'iyle çakışmayacak şekilde seçildi; ikisi aynı anda ayakta olabilir.

Ayağa kaldırmadan önce:

1. **Sırlar** — `.env` içindeki `SecuritySecrets__*` alanlarını doldurun: `openssl rand -base64 32`
2. **JWT anahtarları** — `docker/test/secrets/jwt/` altında üretin (dizin gitignore'ludur):
   ```bash
   mkdir -p secrets/jwt/public
   openssl genrsa -out secrets/jwt/private.pem 2048
   openssl rsa -in secrets/jwt/private.pem -pubout -out secrets/jwt/public/key-2026-01.pem
   ```
   Dosya adı `.env` içindeki `Jwt__CurrentKeyId` ile eşleşmelidir.
3. **Şema** — migration'lar uygulama başlangıcında otomatik çalışmaz, bir kez uygulayın:
   ```bash
   cd ../../ECommerceBackend
   ConnectionStrings__MySql="Server=127.0.0.1;Port=3308;Database=ecommerce;User=ecommerce_app;Password=change-me" \
     dotnet ef database update --project ECommerce.Infrastructure --startup-project ECommerce.Api
   ```

Kapatma: `docker compose down` (verileri de silmek için `-v`).

### prod

`registry.example.com/ecommerce-api:${IMAGE_TAG}` imajını çalıştırır; imajı `docker/Dockerfile` ile build edip push etmeniz gerekir. Şifreler `.env`de değil, external Docker secret'larındadır (`mysql_app_password`, `mysql_root_password`, `redis_password`); JWT anahtarları ve TLS sertifikaları external volume'lardan (`jwt`, `tls`) gelir. Gerekli değişkenler için `docker/prod/.env.example`a bakın.

```bash
docker build -f docker/Dockerfile -t registry.example.com/ecommerce-api:$TAG .
cd docker/prod && IMAGE_TAG=$TAG docker compose up -d
```

Production'da migration bundle kullanılır, uygulama başlangıcında migration çalışmaz.

## Yerel geliştirme (Docker'sız API)

```bash
cd docker/test && cp .env.example .env && docker compose up -d mysql redis mailpit
cd ../../ECommerceBackend
dotnet restore
dotnet ef database update --project ECommerce.Infrastructure --startup-project ECommerce.Api
dotnet run --project ECommerce.Api
```

Bağlantı ayarlarını `dotnet user-secrets` ile veya ortam değişkeni olarak verin; host makineden portlar 3308 (MySQL) ve 6381 (Redis)'dir. API `launchSettings.json` gereği http://localhost:5080'de açılır.

## Port haritası

Üç ortam da aynı anda ayakta olabilecek şekilde ayrıldı. Konteyner içi portların tekrar etmesi sorun değil; her konteynerin kendi ağ namespace'i vardır.

| | Host | Konteyner içi |
|---|---|---|
| API — lokal `dotnet run` | 5080 | — (launchSettings.json) |
| API — dev konteyneri içinde `dotnet run` | 5081 | 5080 |
| API — test stack'i | 5082 | 8080 (Dockerfile `ASPNETCORE_URLS`) |
| VS Code Server (dev) | 8081 | 8080 |
| MySQL | 3307 (dev) / 3308 (test) | 3306 |
| Redis | 6380 (dev) / 6381 (test) | 6379 |
| Mailpit (test) | 1026 SMTP / 8026 UI | 1025 / 8025 |

## Kontroller

```bash
cd ECommerceBackend
dotnet format --verify-no-changes
dotnet test
```

Integration testleri Testcontainers kullanır — çalışan bir Docker daemon'ı gerektirir, `docker/test` stack'ine ihtiyaç duymaz.
