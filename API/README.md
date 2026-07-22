# ECommerce API

Çok satıcılı (marketplace) bir e-ticaret platformunun backend'i. .NET 9, MySQL 8.4/InnoDB ve Redis üzerine kurulu; müşteri, satıcı ve yönetici olmak üzere üç rolü ve sipariş yaşam döngüsünün tamamını (sepet → ödeme → paketleme → kargo → teslimat) kapsıyor.

## İçindekiler

- [Hızlı başlangıç](#hızlı-başlangıç)
- [Mimari](#mimari)
- [Docker ortamları](#docker-ortamları)
- [Port haritası](#port-haritası)
- [OpenAPI / Swagger](#openapi--swagger)
- [Mailpit — e-postaları yakalama](#mailpit--e-postaları-yakalama)
- [E-posta (SMTP) yapılandırması](#e-posta-smtp-yapılandırması)
- [Kimlik doğrulama](#kimlik-doğrulama)
- [Yanıt zarfı ve hata kodları](#yanıt-zarfı-ve-hata-kodları)
- [Endpoint referansı](#endpoint-referansı)
- [İstek DTO'ları](#i̇stek-dtoları)
- [Durum makineleri](#durum-makineleri)
- [Rate limiting](#rate-limiting)
- [Veritabanı ve migration](#veritabanı-ve-migration)
- [Testler](#testler)
- [Yapılandırma](#yapılandırma)

---

## Hızlı başlangıç

Gereksinim: Docker. Başka hiçbir şeye ihtiyaç yok — .NET SDK'sı bile gerekmiyor.

```bash
cd docker/test
cp .env.example .env
```

`.env` içinde iki alanı doldurun:

```bash
# Her biri 32 baytlık base64 değer
openssl rand -base64 32   # → SecuritySecrets__HmacPepperBase64
openssl rand -base64 32   # → SecuritySecrets__EncryptionKeyBase64
```

JWT imzalama anahtarlarını üretin (dizin `.gitignore`'ludur, anahtarlar repoya girmez):

```bash
mkdir -p secrets/jwt/public
openssl genrsa -out secrets/jwt/private.pem 2048
openssl rsa -in secrets/jwt/private.pem -pubout -out secrets/jwt/public/key-2026-01.pem
```

> Dosya adı (`key-2026-01`) `.env` içindeki `Jwt__CurrentKeyId` ile eşleşmelidir.

Ayağa kaldırın:

```bash
docker compose up -d --build
```

İlk çalıştırmada imaj derlenir (~1-2 dk). API açılırken veritabanı şemasını kendisi uygular ve rolleri basar.

**http://127.0.0.1:5082/swagger** → Swagger UI

Kapatma: `docker compose down` · Verileri de silmek için: `docker compose down -v`

---

## Mimari

Katmanlı (Clean Architecture) yapı; bağımlılıklar yalnızca içeri doğru akar.

```
ECommerce.Domain          Entity'ler, enum'lar, domain kuralları. Hiçbir katmana bağımlı değil.
      ▲
ECommerce.Application     Feature'lar (Command/Query/Handler/Validator), arayüzler, Result<T>.
      ▲                   Yalnızca Domain'e bağımlı; EF/Redis bilmez.
ECommerce.Infrastructure  EF Core, Redis, JWT, Argon2, SMTP, dosya depolama, outbox.
      ▲                   Application'daki arayüzleri implemente eder.
ECommerce.Api             Controller'lar, middleware, yetkilendirme, rate limiting, OpenAPI.
```

Bu kurallar [LayerDependencyTests](ECommerceBackend/tests/ECommerce.ArchitectureTests/LayerDependencyTests.cs) ile test edilir — örneğin controller'ların doğrudan `Microsoft.EntityFrameworkCore` veya `StackExchange.Redis` kullanması testi kırar.

**Feature deseni:** her endpoint `Features/<Alan>/<İşlem>/` altında üç dosyadır — `XCommand.cs` (girdi), `XHandler.cs` (iş mantığı), `XValidator.cs` (FluentValidation). Handler'lar exception fırlatmak yerine `Result<T>` döndürür; HTTP durum kodu eşlemesi [ResultExtensions.cs](ECommerceBackend/ECommerce.Api/Extensions/ResultExtensions.cs)'te tek noktada yapılır.

**Dikkate değer altyapı:**

| Konu | Nasıl |
|---|---|
| Parola | Argon2id ([Argon2PasswordHasher](ECommerceBackend/ECommerce.Infrastructure/Security/Argon2PasswordHasher.cs)), 64 MB bellek maliyeti |
| Token iptali | Redis'te jti kara listesi + `securityVersion` sayacı; çıkışta anında geçersizleşir |
| Refresh token | Rotasyon + yeniden kullanım tespiti; tekrar kullanılırsa tüm oturumlar iptal edilir |
| E-posta | Transactional outbox — mesaj sipariş ile aynı transaction'da yazılır, `OutboxProcessor` 2 sn'de bir gönderir |
| Hassas veri | Outbox yükü AES-GCM ile şifreli ([AesGcmSecretProtector](ECommerceBackend/ECommerce.Infrastructure/Security/AesGcmSecretProtector.cs)) |
| Eşzamanlılık | `EntityBase.Version` concurrency token; checkout `Serializable` izolasyonda |
| Fotoğraf | ImageSharp ile yeniden kodlanır, EXIF/XMP/IPTC metadata silinir |
| İzlenebilirlik | `X-Correlation-Id` başlığı; yoksa üretilir, log scope'una eklenir, yanıtta döner |

---

## Docker ortamları

### `docker/dev` — konteyner içinde geliştirme

Tarayıcıdan erişilen, .NET SDK'sı ve eklentileri (csharpier, dotnet-ef) otomatik kurulan bir VS Code Server; yanında MySQL ve Redis ile gelir.

```bash
cd docker/dev
docker compose -f docker-compose.dev.yml up -d    # Windows: up.bat
```

http://127.0.0.1:8081 → parola `123456`

### `docker/test` — tüm stack'i çalıştırma

API imajını derler ve bağımlılıklarıyla birlikte çalıştırır. Şemayı API kendisi uygular, `SeedOnStartup=true` ile roller basılır.

```bash
cd docker/test && docker compose up -d --build
```

### `docker/prod` — canlı

nginx (TLS sonlandırma + rate limit) arkasında, dış dünyaya kapalı `internal` ağda çalışan API. Şifreler `.env`de değil **external Docker secret**'larında (`mysql_app_password`, `mysql_root_password`, `redis_password`); JWT anahtarları ve TLS sertifikaları external volume'lardan (`jwt`, `tls`) gelir. Konteynerler `read_only` rootfs ile çalışır.

```bash
docker build -f docker/Dockerfile -t registry.example.com/ecommerce-api:$TAG .
docker push registry.example.com/ecommerce-api:$TAG
cd docker/prod && IMAGE_TAG=$TAG docker compose up -d
```

Prod'da Swagger kapalıdır ve migration açılışta çalışmaz — dağıtım adımında migration bundle kullanılır.

---

## Port haritası

Üç ortam aynı anda ayakta olabilecek şekilde ayrıldı. Konteyner içi portların tekrar etmesi sorun değildir; her konteynerin kendi ağ namespace'i vardır.

| | Host | Konteyner içi |
|---|---|---|
| API — lokal `dotnet run` | 5080 | — (launchSettings.json) |
| API — dev konteyneri içinde | 5081 | 5080 |
| API — test stack'i | **5082** | 8080 |
| VS Code Server (dev) | 8081 | 8080 |
| MySQL | 3307 (dev) / 3308 (test) | 3306 |
| Redis | 6380 (dev) / 6381 (test) | 6379 |
| Mailpit (test) | 1026 SMTP / **8026** UI | 1025 / 8025 |

Tüm portlar `127.0.0.1`e bağlanır; dış ağdan erişilemez.

---

## OpenAPI / Swagger

| | Adres |
|---|---|
| Swagger UI | http://127.0.0.1:5082/swagger |
| OpenAPI JSON | http://127.0.0.1:5082/swagger/v1/swagger.json |

Swagger yalnızca `ASPNETCORE_ENVIRONMENT=Development` iken açıktır ([Program.cs:88](ECommerceBackend/ECommerce.Api/Program.cs:88)).

**İstemci kodu üretmek için** OpenAPI dökümanını doğrudan kullanabilirsiniz:

```bash
curl -s http://127.0.0.1:5082/swagger/v1/swagger.json -o openapi.json
```

**Swagger UI'da korumalı endpoint denemek:** [Mailpit bölümündeki adımları](#mailpit--e-postaları-yakalama) izleyin — kayıt, kodu Mailpit'ten okuma ve doğrulama. `email/verify` doğrudan token döndürür; onu sağ üstteki **Authorize** kutusuna girin.

---

## Mailpit — e-postaları yakalama

**http://127.0.0.1:8026**

### Nedir

Mailpit, geliştirme ve test için yazılmış **sahte bir SMTP sunucusudur**. Uygulamanın gönderdiği e-postaları kabul eder, ama hiçbirini gerçek alıcıya iletmez — hepsini kendi içinde tutar ve bir web arayüzünde gösterir. Kendi gelen kutunuz gibi çalışır, sadece içine düşen her şey sizin uygulamanızdan gelir.

### Neden gerekli

Bu API kimlik doğrulamayı e-posta üzerinden yapıyor. [OutboxMessageDispatcher.cs:21](ECommerceBackend/ECommerce.Infrastructure/Outbox/OutboxMessageDispatcher.cs:21):

```csharp
await email.SendAsync(to, "Doğrulama kodunuz", $"<p>Doğrulama kodunuz: <strong>{code}</strong></p>", ct);
```

Şu akışların hepsi bu koda dayanır:

| Akış | Gönderilen |
|---|---|
| Müşteri/satıcı kaydı | Hesap doğrulama kodu |
| Parolamı unuttum | Sıfırlama kodu |
| E-posta değiştirme | Yeni adrese doğrulama kodu |

Mailpit olmasaydı test ortamında iki kötü seçenek kalırdı:

1. **SMTP sunucusu hiç olmaz** → bağlantı reddedilir, kayıt akışı yarım kalır, hiçbir hesabı aktive edemezsiniz
2. **Gerçek bir sağlayıcı (Gmail vb.) bağlanır** → test verisiyle çalışırken **gerçek insanlara e-posta gider**; `ahmet@gmail.com` diye uydurma bir adresle kayıt denerseniz o adresin gerçek sahibine posta gitmiş olur

Mailpit ikisini de çözer: akış uçtan uca çalışır, hiçbir e-posta dışarı çıkmaz.

### Nasıl kullanılır

Örnek: kayıt olup hesabı doğrulama.

**1.** Swagger'dan (`http://127.0.0.1:5082/swagger`) kayıt olun:

```http
POST /api/v1/auth/customer/register
{
  "email": "test@ornek.com",
  "password": "ParolaGuclu123",
  "passwordConfirm": "ParolaGuclu123",
  "firstName": "Test",
  "lastName": "Kullanici",
  "phoneNumber": "+905551112233"
}
```

> **Doğrulama kuralları** ([RegisterCustomerValidator](ECommerceBackend/ECommerce.Application/Features/Auth/RegisterCustomer/RegisterCustomerValidator.cs)):
> parola **en az 12 karakter** olmalı ve büyük harf, küçük harf ve rakam içermeli;
> telefon **E.164** formatında olmalı — `+` ile başlar, ülke kodu dahil 8-15 hane (`+905551112233`).

Yanıtta gelen `sessionId` değerini not edin.

**2.** http://127.0.0.1:8026 adresini açın. E-posta birkaç saniye içinde düşer — `OutboxProcessor` outbox tablosunu 2 saniyede bir tarar, yani anında görünmeyebilir. Mesajı açıp **6 haneli kodu** okuyun.

**3.** Kodu doğrulayın:

```http
POST /api/v1/auth/email/verify
{ "sessionId": "<1. adımdaki sessionId>", "code": "<Mailpit'ten okuduğunuz kod>" }
```

**Bu istek doğrudan `accessToken` ve `refreshToken` döndürür** — ayrıca `login` çağırmanıza gerek yoktur, doğrulama ile oturum açılmış olur.

**4.** Dönen `accessToken`'ı Swagger'daki **Authorize** kutusuna girin.

### İpuçları

- **E-posta gelmiyorsa:** `docker compose logs api | grep -i outbox` ile outbox işlemcisini kontrol edin. E-postalar doğrudan gönderilmez; önce `outbox_messages` tablosuna yazılır, arka plan servisi gönderir.
- **Kod süresi 5 dakikadır** (`Otp__LifetimeMinutes`). Süre dolarsa `POST /api/v1/auth/email/resend` ile yenisini isteyin — ama 10 dakikada en fazla 3 kez (`otp-resend` rate limit).
- **Deneme hakkı 5'tir** (`Otp__MaxAttempts`); aşılırsa oturum kilitlenir.
- **Veriler kalıcı değildir:** Mailpit'e volume tanımlanmamıştır, `docker compose down` sonrası yakalanan e-postalar silinir. Test ortamı için istenen davranış budur.
- Mailpit'in kendi arama, HTML/metin önizleme ve ham kaynak görüntüleme özellikleri vardır — HTML şablonunu incelemek için kullanışlıdır.

> **Prod'da Mailpit yoktur ve olmamalıdır.** `docker/prod` gerçek bir SMTP sağlayıcısına bağlanır; aşağıya bakın.

---

## E-posta (SMTP) yapılandırması

Tüm SMTP ayarları `.env` dosyasındadır — `docker/test/.env` ve `docker/prod/.env`.

| Değişken | Açıklama |
|---|---|
| `Smtp__Host` | Sunucu adresi |
| `Smtp__Port` | Port (STARTTLS için 587) |
| `Smtp__UseTls` | `true` → STARTTLS, `false` → şifresiz |
| `Smtp__UserName` | Kimlik doğrulama kullanıcısı (boşsa doğrulama yapılmaz) |
| `Smtp__Password` | Parola / API anahtarı |
| `Smtp__FromAddress` | Gönderen adresi |
| `Smtp__FromName` | Gönderen görünen adı |

### Test ortamı (varsayılan)

```ini
Smtp__Host=mailpit
Smtp__Port=1025      # konteyner içi port, host'taki 1026 değil
Smtp__UseTls=false
```

### Gmail

Gmail **normal hesap parolasını kabul etmez**, "Uygulama Parolası" gerekir:

1. Google Hesabı → Güvenlik → **2 Adımlı Doğrulama**'yı açın (zorunlu ön koşul)
2. Google Hesabı → Güvenlik → **Uygulama Parolaları** → yeni parola üretin
3. Üretilen 16 karakterli parolayı **boşlukları silerek** girin

```ini
Smtp__Host=smtp.gmail.com
Smtp__Port=587
Smtp__UseTls=true
Smtp__UserName=hesabiniz@gmail.com
Smtp__Password=<16-karakterli-uygulama-parolasi>
Smtp__FromAddress=hesabiniz@gmail.com
Smtp__FromName=ECommerce
```

> Gmail'in günlük gönderim limiti ~500'dür ve işlemsel e-posta için tasarlanmamıştır. Gerçek trafikte aşağıdaki sağlayıcıları tercih edin.

### Diğer sağlayıcılar

| Sağlayıcı | Host | Port | Not |
|---|---|---|---|
| SendGrid | `smtp.sendgrid.net` | 587 | `Smtp__UserName=apikey`, parola = API anahtarı |
| Mailgun | `smtp.mailgun.org` | 587 | Alan adı doğrulaması gerekir |
| Amazon SES | `email-smtp.<bölge>.amazonaws.com` | 587 | SMTP kimlik bilgileri IAM'den ayrı üretilir |

Hepsinde `Smtp__Port=587` + `Smtp__UseTls=true` (STARTTLS) çalışır.

### Prod uyarısı

`docker/prod/.env` içinde SMTP alanları boş bırakılırsa **kayıt ve parola sıfırlama akışları sessizce çalışmaz** — kullanıcı kayıt olur, doğrulama kodu asla gelmez, hesabını aktive edemez. Uygulama açılışta bu durumu hata olarak bildirmez; sorun ilk kayıt denemesinde ortaya çıkar.

---

## Kimlik doğrulama

RS256 imzalı JWT. Access token 15 dakika, refresh token 14 gün geçerlidir.

```
Authorization: Bearer <accessToken>
```

**Token claim'leri:** `sub` (hesap id), `jti` (token id), `sid` (oturum id), `role`, `securityVersion`

**Roller ve politikalar:**

| Politika | Rol | Kullanan controller |
|---|---|---|
| `CustomerOnly` | Customer | Customer, Orders, Shopping (sepet/favori/yorum) |
| `SellerOnly` | Seller | Seller (ürün, sipariş, profil) |
| `AdminOnly` | Admin | Admin |
| *(sadece `Authorize`)* | herhangi biri | Account, fotoğraf yükleme, çıkış |

**Her istekte iki katmanlı kontrol yapılır:** JWT imza doğrulaması + Redis'ten `jti` kara listesi ve `securityVersion` kontrolü ([CustomJwtBearerEvents](ECommerceBackend/ECommerce.Api/Authentication/CustomJwtBearerEvents.cs)). Bu sayede çıkış yapıldığında veya parola değiştiğinde token'lar süresi dolmadan geçersizleşir.

**Refresh akışı:** `POST /api/v1/auth/refresh-token` her çağrıda yeni bir refresh token üretir ve eskisini iptal eder. Eski bir token ikinci kez kullanılırsa hırsızlık varsayılır ve **kullanıcının tüm oturumları iptal edilir** (`REFRESH_TOKEN_REUSE`).

---

## Yanıt zarfı ve hata kodları

Tüm yanıtlar aynı zarfla döner ([ApiResponse](ECommerceBackend/ECommerce.Api/Contracts/Common/ApiResponse.cs)):

```json
{
  "data": { },
  "isSuccess": true,
  "message": "Kategoriler listelendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-22T10:32:45.918Z"
}
```

Hata durumunda `data: null`, `errors` dolu:

```json
{
  "data": null,
  "isSuccess": false,
  "message": "One or more validation errors occurred.",
  "code": 400,
  "errors": { "email": ["Geçerli bir e-posta adresi girin."] },
  "timestamp": "2026-07-22T10:33:01.204Z"
}
```

**JSON isimlendirme:** camelCase, ancak `Utc` soneki atılır ([ApiJsonNamingPolicy](ECommerceBackend/ECommerce.Api/Contracts/Common/ApiJsonNamingPolicy.cs)). Yani `CreatedAtUtc` → `createdAt`. Tüm tarihler UTC'dir.

### Hata kodu → HTTP eşlemesi

| Kod | HTTP | Anlamı |
|---|---|---|
| `UNAUTHORIZED`, `INVALID_CREDENTIALS`, `INVALID_REFRESH_TOKEN`, `REFRESH_TOKEN_REUSE` | 401 | Kimlik doğrulama başarısız |
| `FORBIDDEN` | 403 | Yetki yok |
| `NOT_FOUND` | 404 | Kayıt bulunamadı |
| `CONFLICT`, `EMAIL_ALREADY_EXISTS`, `REVIEW_ALREADY_EXISTS`, `IDEMPOTENCY_KEY_REUSED` | 409 | Çakışma |
| `PAYMENT_DECLINED` | 422 | Ödeme reddedildi |
| `OTP_COOLDOWN`, `RATE_LIMITED` | 429 | Çok fazla istek |
| aşağıdaki iş kuralı kodları ve `VALIDATION_ERROR` | 400 | Geçersiz istek |

**İş kuralı kodları:**

| Kod | Ne zaman |
|---|---|
| `EMAIL_NOT_VERIFIED` | E-posta doğrulanmadan giriş denendi |
| `ACCOUNT_LOCKED` | Ardışık hatalı giriş sonrası geçici kilit |
| `INVALID_OTP` | Doğrulama kodu hatalı veya süresi dolmuş |
| `CART_EMPTY` | Boş sepetle checkout |
| `INSUFFICIENT_STOCK` | Sepetteki bir üründe yeterli stok yok |
| `PRODUCT_UNAVAILABLE` | Ürün pasif veya silinmiş |
| `ORDER_CANNOT_BE_CANCELLED` | Sipariş iptal edilebilir durumda değil |
| `INVALID_PACKAGE_TRANSITION` | Geçersiz paket durum geçişi (ör. Paid → Delivered) |
| `CARRIER_INACTIVE` | Seçilen kargo firması pasif |
| `SHIPMENT_NOT_FOUND` | Kargo kaydı yok |
| `VERIFIED_PURCHASE_REQUIRED` | Satın alınmamış ürüne yorum denendi |

---

## Endpoint referansı

54 endpoint. `🔓` herkese açık · `🔒` giriş gerekli · `👤` Customer · `🏪` Seller · `⚙️` Admin

### Kimlik doğrulama — `/api/v1/auth`

| | Endpoint | İstek | Açıklama |
|---|---|---|---|
| 🔓 | `POST /customer/register` | `RegisterCustomerRequest` | Müşteri kaydı → OTP e-postası |
| 🔓 | `POST /seller/register` | `RegisterSellerRequest` | Satıcı kaydı → OTP e-postası |
| 🔓 | `POST /email/verify` | `VerifyEmailRequest` | E-posta doğrulama |
| 🔓 | `POST /email/resend` | `ResendEmailRequest` | Kodu yeniden gönder |
| 🔓 | `POST /login` | `LoginRequest` | Access + refresh token |
| 🔓 | `POST /refresh-token` | `RefreshTokenRequest` | Token yenileme (rotasyonlu) |
| 🔓 | `POST /forgot-password` | `ForgotPasswordRequest` | Sıfırlama kodu gönder |
| 🔓 | `POST /reset-password` | `ResetPasswordRequest` | Parolayı sıfırla |
| 🔒 | `POST /logout` | — | Oturumu ve token'ları iptal et |

### Hesap — `/api/v1/account/me` 🔒

| | Endpoint | İstek |
|---|---|---|
| 🔒 | `GET /` | — |
| 🔒 | `PUT /` | `UpdateAccountRequest` |
| 🔒 | `PUT /password` | `ChangePasswordRequest` |
| 🔒 | `PUT /email` | `StartEmailChangeRequest` |
| 🔒 | `POST /email/verify` | `VerifyEmailChangeRequest` |
| 🔒 | `POST /email/resend` | `ResendEmailChangeRequest` |

### Katalog — `/api/v1` 🔓

| | Endpoint | Sorgu parametreleri |
|---|---|---|
| 🔓 | `GET /products` | `page=1` `size=12` `q` `categoryId` `sellerId` `minPrice` `maxPrice` `inStock` `sortBy=newest` |
| 🔓 | `GET /products/{id}` | — |
| 🔓 | `GET /categories` | — |
| 🔓 | `GET /products/{id}/reviews` | `page=1` `size=10` `sortBy=newest\|oldest\|rating_desc\|rating_asc` |
| 👤 | `POST /products/{id}/reviews` | `ReviewWriteRequest` |
| 👤 | `PUT /products/{productId}/reviews/{reviewId}` | `ReviewWriteRequest` |
| 👤 | `DELETE /products/{productId}/reviews/{reviewId}` | — |

> Yorum yazmak için ürünün **teslim edilmiş** bir siparişte satın alınmış olması gerekir, aksi halde `VERIFIED_PURCHASE_REQUIRED` döner.

### Sepet ve favoriler — `/api/v1` 👤

| | Endpoint | İstek |
|---|---|---|
| 👤 | `GET /cart` · `DELETE /cart` | — |
| 👤 | `POST /cart/items` | `CartItemRequest` |
| 👤 | `PUT /cart/items/{productId}` | `UpdateCartItemRequest` |
| 👤 | `DELETE /cart/items/{productId}` | — |
| 👤 | `GET /favorites` | `page=1` `size=20` |
| 👤 | `POST /favorites/{productId}` · `DELETE /favorites/{productId}` | — |

### Siparişler — `/api/v1` 👤

| | Endpoint | İstek |
|---|---|---|
| 👤 | `POST /orders/checkout` | `CheckoutRequest` + **`Idempotency-Key` başlığı (zorunlu)** |
| 👤 | `GET /orders` | `page=1` `size=10` `status` |
| 👤 | `GET /orders/{id}` | — |
| 👤 | `POST /orders/{id}/cancel` | `CancelOrderRequest` |
| 👤 | `POST /payments/simulate` | `SimulatePaymentRequest` |

**Checkout hakkında** ([OrderService.cs](ECommerceBackend/ECommerce.Infrastructure/Orders/OrderService.cs)):

- `Idempotency-Key` başlığı **zorunludur**. İstek `checkout_requests` tablosuna kaydedilir; aynı anahtarla farklı bir gövde gönderilirse `IDEMPOTENCY_KEY_REUSED` döner. Ağ hatasında güvenle tekrar denenebilir.
- `Serializable` izolasyonda çalışır; stok kontrolü ve düşümü atomiktir.
- Sepet birden fazla satıcının ürününü içeriyorsa sipariş **satıcı başına paketlere** bölünür (`GroupBy(SellerProfileId)`). Her paketi ilgili satıcı ayrı ayrı hazırlar ve kargolar.
- Ürün başlığı ve fiyatı sipariş anında **snapshot**'lanır; satıcı sonradan değiştirse bile sipariş etkilenmez.
- Sipariş iptalinde stok geri yüklenir (`StockReturnedAtUtc` ile bir kez).

### Müşteri profili — `/api/v1/customer/me` 👤

| | Endpoint | İstek |
|---|---|---|
| 👤 | `DELETE /` | `DeleteCustomerRequest` |
| 👤 | `GET /addresses` · `POST /addresses` | `AddressWriteRequest` |
| 👤 | `GET\|PUT\|DELETE /addresses/{id}` | `AddressWriteRequest` |

### Satıcı — `/api/v1/seller` 🏪

| | Endpoint | İstek |
|---|---|---|
| 🏪 | `GET /dashboard` | `from` `to` |
| 🏪 | `GET /profile` · `PUT /profile` | `UpdateSellerProfileRequest` |
| 🏪 | `GET /products` | `page=1` `size=10` `q` `isActive` |
| 🏪 | `POST /products` · `PUT /products/{id}` | `SellerProductWriteRequest` |
| 🏪 | `GET /products/{id}` · `DELETE /products/{id}` | — |
| 🏪 | `GET /orders` | `page=1` `size=10` `status` `from` `to` |
| 🏪 | `GET /orders/{packageId}` | — |
| 🏪 | `POST /orders/{packageId}/prepare` | — |
| 🏪 | `POST /orders/{packageId}/ship` | `ShipPackageRequest` |
| 🏪 | `POST /orders/{packageId}/deliver` | — |
| 🏪 | `GET /shipping-carriers` | — |

### Yönetim — `/api/v1/admin` ⚙️

| | Endpoint | İstek |
|---|---|---|
| ⚙️ | `GET /dashboard` | `from` `to` |
| ⚙️ | `GET /users` | `page=1` `size=20` `q` `role` `isActive` |
| ⚙️ | `GET /users/{id}` | — |
| ⚙️ | `GET /sellers` · `GET /sellers/{id}` | `page=1` `size=20` `q` `isActive` |
| ⚙️ | `GET /orders` · `GET /orders/{id}` | `page=1` `size=20` `status` `from` `to` |
| ⚙️ | `GET /shipping-carriers` · `GET /shipping-carriers/{id}` | — |
| ⚙️ | `POST /shipping-carriers` · `PUT /shipping-carriers/{id}` | `ShippingCarrierWriteRequest` |
| ⚙️ | `DELETE /shipping-carriers/{id}` | — |

### Diğer

| | Endpoint | Açıklama |
|---|---|---|
| 🔒 | `POST /api/v1/photos` | `multipart/form-data`, maks. **5 MB**, jpeg/png/webp |
| 🔓 | `GET /api/v1/photos/{id}` | Fotoğrafı indir |
| 🔓 | `GET /api/v1/metadata/statuses` | Tüm durum enum'larının listesi |
| 🔓 | `GET /health/live` | Süreç ayakta mı |
| 🔓 | `GET /health/ready` | MySQL + Redis erişilebilir mi |

---

## İstek DTO'ları

Tanımlar: [ECommerce.Api/Contracts/V1/](ECommerceBackend/ECommerce.Api/Contracts/V1/)

### Kimlik doğrulama

```csharp
RegisterCustomerRequest(string Email, string Password, string PasswordConfirm,
                        string FirstName, string LastName, string PhoneNumber)

RegisterSellerRequest(string Email, string Password, string PasswordConfirm,
                      string FirstName, string LastName, string PhoneNumber,
                      string StoreName, string TaxNumber, string TaxOffice)

LoginRequest(string Email, string Password)
RefreshTokenRequest(string RefreshToken)
VerifyEmailRequest(string SessionId, string Code)
ResendEmailRequest(string Email)
ForgotPasswordRequest(string Email)
ResetPasswordRequest(string SessionId, string Code, string NewPassword, string NewPasswordConfirm)
```

### Hesap

```csharp
UpdateAccountRequest(string FirstName, string LastName, string PhoneNumber)
ChangePasswordRequest(string CurrentPassword, string NewPassword, string NewPasswordConfirm)
StartEmailChangeRequest(string NewEmail, string Password)
VerifyEmailChangeRequest(string SessionId, string Code)
ResendEmailChangeRequest(string Password)
DeleteCustomerRequest(string Password)
```

### Alışveriş

```csharp
CartItemRequest(string ProductId, int Quantity)
UpdateCartItemRequest(int Quantity)
ReviewWriteRequest(int Rating, string Comment, IReadOnlyList<string> PhotoIds)
AddressWriteRequest(string Title, string AddressLine, string City,
                    string District, string ZipCode, string PhoneNumber)
```

### Sipariş ve ödeme

```csharp
PaymentCardRequest(string CardHolderName, string CardNumber,
                   int ExpireMonth, int ExpireYear, string Cvv)

CheckoutRequest(string AddressId, PaymentCardRequest PaymentCard)
SimulatePaymentRequest(decimal Amount, PaymentCardRequest PaymentCard)
CancelOrderRequest(string CancelReason)
```

### Satıcı

```csharp
UpdateSellerProfileRequest(string StoreName, string Description, string? LogoId, string TaxOffice)

SellerProductWriteRequest(string Title, string Description, decimal Price, int Stock,
                          string CategoryId, IReadOnlyList<string> PhotoIds,
                          IReadOnlyDictionary<string, string> Features, bool IsActive)

ShipPackageRequest(string CarrierId, string TrackingNumber)
```

### Yönetim

```csharp
ShippingCarrierWriteRequest(string Name, string Code, string? LogoId, decimal FlatFee,
                            int EstimatedDeliveryDays, string TrackingUrlTemplate, bool IsActive)
```

> **Yanıt DTO'ları** feature klasörlerinde `*Dtos.cs` dosyalarındadır — örneğin [CatalogDtos.cs](ECommerceBackend/ECommerce.Application/Features/Catalog/CatalogDtos.cs), [OrderDtos.cs](ECommerceBackend/ECommerce.Application/Features/Orders/OrderDtos.cs). Tam ve güncel şemalar için OpenAPI dökümanına bakın.

---

## Durum makineleri

`GET /api/v1/metadata/statuses` bu listelerin tamamını çalışma zamanında döner.

**Sipariş** ([OrderStatus](ECommerceBackend/ECommerce.Domain/Common/Enums/OrderStatus.cs)) — paketlerin durumundan türetilir:

```
Paid → Preparing → PartiallyShipped → Shipped
                 → PartiallyDelivered → Delivered
                 → PartiallyCancelled → Cancelled
```

**Paket** ([PackageStatus](ECommerceBackend/ECommerce.Domain/Common/Enums/PackageStatus.cs)) — satıcının kontrol ettiği birim:

```
Paid → Preparing → Shipped → Delivered
     ↘ Cancelled
```

| Geçiş | Endpoint |
|---|---|
| Paid → Preparing | `POST /seller/orders/{packageId}/prepare` |
| Preparing → Shipped | `POST /seller/orders/{packageId}/ship` |
| Shipped → Delivered | `POST /seller/orders/{packageId}/deliver` |

**Ödeme:** `Pending → Success \| Failed` · **Kargo:** `NotCreated → LabelCreated → InTransit → Delivered \| Cancelled`

---

## Rate limiting

Redis tabanlı, atomik (Lua script) sayaçlar. Tanımlar: [RateLimitPolicyRegistry](ECommerceBackend/ECommerce.Api/RateLimiting/RateLimitPolicyRegistry.cs)

| Politika | Limit | Pencere | Redis düşerse |
|---|---|---|---|
| `login` | 10 | 15 dk | **kapalı** (istek reddedilir) |
| `otp-verify` | 20 | 5 dk | **kapalı** |
| `otp-resend` | 3 | 10 dk | **kapalı** |
| `forgot-password` | 3 | 15 dk | **kapalı** |
| `refresh` | 20 | 1 dk | **kapalı** |
| `upload` | 20 | 10 dk | **kapalı** |
| `checkout` | 5 | 1 dk | **kapalı** |
| `mutation` | 60 | 1 dk | açık (istek geçer) |

Güvenlikle ilgili politikalar **fail-closed**: Redis erişilemezse istek reddedilir; böylece cache kesintisi brute-force penceresi açmaz. Yalnızca genel `mutation` politikası fail-open'dır.

Yanıt başlıkları: `RateLimit-Remaining`, `RateLimit-Reset`, limit aşımında `Retry-After` (429).

---

## Veritabanı ve migration

24 tablo, 57 index (17'si unique), 38 foreign key. Tablo ve sütun adları `snake_case` (EFCore.NamingConventions), charset `utf8mb4`, izolasyon `READ-COMMITTED`.

Migration'lar `dotnet ef` ile üretilir ve **repoya commit edilir**; elle yazılmaz. Ayrıntı: [Migrations/README.md](ECommerceBackend/ECommerce.Infrastructure/Persistence/Migrations/README.md)

```bash
cd ECommerceBackend
dotnet ef migrations add <Ad> --project ECommerce.Infrastructure \
  --startup-project ECommerce.Api --output-dir Persistence/Migrations
```

**Uygulama:** Development ortamında API açılışta `MigrateAsync()` çağırır ([Program.cs:93](ECommerceBackend/ECommerce.Api/Program.cs:93)); EF exclusive kilit aldığı için birden fazla instance güvenlidir. **Production'da açılışta çalışmaz** — dağıtım adımında migration bundle kullanılır:

```bash
dotnet ef migrations bundle --self-contained --target-runtime linux-x64 \
  --project ECommerce.Infrastructure --startup-project ECommerce.Api --output artifacts/efbundle
```

> ⚠️ [AppDbContextFactory](ECommerceBackend/ECommerce.Infrastructure/Persistence/AppDbContextFactory.cs) (design-time) ile [DependencyInjection](ECommerceBackend/ECommerce.Infrastructure/DependencyInjection.cs) (runtime) aynı `DbContextOptions` yapılandırmasını kurmak zorundadır. İkisi ayrışırsa `dotnet ef` uygulamanınkinden farklı bir şema üretir.

---

## Testler

| Proje | Kapsam |
|---|---|
| `ECommerce.UnitTests` | `Result<T>`, Argon2 hash, sipariş durumu toplama |
| `ECommerce.ArchitectureTests` | Katman bağımlılık kuralları (NetArchTest) |
| `ECommerce.ContractTests` | Rota listesi ve JSON isimlendirme sözleşmesi |
| `ECommerce.IntegrationTests` | Checkout eşzamanlılığı, rate limit atomikliği, token iptali, refresh yeniden kullanımı, Redis kesintisi |

```bash
cd ECommerceBackend
dotnet test
```

Integration testleri **Testcontainers** kullanır: kendi MySQL ve Redis konteynerlerini başlatır, `docker/test` stack'ine ihtiyaç duymaz. Çalışan bir Docker daemon'ı gerekir.

Lokalde .NET SDK yoksa dev konteyneri içinden çalıştırın.

---

## Yapılandırma

**Compose dosyalarında sabit değer yoktur** — `docker/test` ve `docker/prod` için tüm ayarlar ilgili klasördeki `.env` dosyasındadır. Şablon ve açıklamalar için `.env.example`a bakın:

- [docker/test/.env.example](docker/test/.env.example)
- [docker/prod/.env.example](docker/prod/.env.example)

Ayarlar `appsettings.json` → ortam değişkeni sırasıyla okunur. İç içe anahtarlar `__` ile yazılır: `ConnectionStrings__MySql`, `Jwt__Issuer`. Dizi elemanları indeksle: `AllowedOrigins__0`.

| Anahtar | Varsayılan | Açıklama |
|---|---|---|
| `Jwt__AccessTokenMinutes` | 15 | Access token ömrü |
| `Jwt__RefreshTokenDays` | 14 | Refresh token ömrü |
| `Jwt__CurrentKeyId` | `key-2026-01` | İmzalama anahtarı adı (`public/` altındaki dosya adı) |
| `Otp__LifetimeMinutes` | 5 | Doğrulama kodu ömrü |
| `Otp__MaxAttempts` | 5 | Kod deneme hakkı |
| `Otp__ResendCooldownSeconds` | 60 | Yeniden gönderim bekleme süresi |
| `Storage__MaxPhotoBytes` | 5242880 | Fotoğraf boyut sınırı (5 MB) |
| `PasswordHash__MemorySizeKb` | 65536 | Argon2 bellek maliyeti |
| `SeedOnStartup` | false | Açılışta örnek veri (yalnızca Development) |
| `AllowedOrigins__0` | — | CORS'a izin verilen frontend adresi |
| `Smtp__*` | — | E-posta ayarları → [SMTP bölümü](#e-posta-smtp-yapılandırması) |
| `SecuritySecrets__HmacPepperBase64` | — | **Zorunlu**, 32 bayt base64 |
| `SecuritySecrets__EncryptionKeyBase64` | — | **Zorunlu**, 32 bayt base64 |

> ⚠️ `SecuritySecrets__*` değerleri **kalıcıdır**. `EncryptionKeyBase64` değişirse şifreli outbox kayıtları okunamaz hale gelir; `HmacPepperBase64` değişirse mevcut kullanıcılar giriş yapamaz.

**Parolalar nerede durur:**

| Ortam | MySQL / Redis parolası | SMTP parolası |
|---|---|---|
| `test` | `.env` | `.env` |
| `prod` | **external Docker secret** (`docker secret create`) | `.env` |

Prod'da veritabanı parolaları bilinçli olarak `.env`de değildir: MySQL ve Redis imajları parolayı dosyadan okumayı destekler (`MYSQL_PASSWORD_FILE`), bu yöntemde parola `docker inspect` çıktısında ve süreç ortamında görünmez. Uygulama SMTP parolasını dosyadan okuyamadığı için o `.env`de kalır — sunucuda `chmod 600 .env` uygulayın.

Yerel geliştirmede (Docker'sız) sırları `dotnet user-secrets` ile verin. `.env`, `secrets/` ve `storage/` dizinleri `.gitignore`'ludur.

### Docker'sız yerel çalıştırma

```bash
cd docker/test && cp .env.example .env && docker compose up -d mysql redis mailpit
cd ../../ECommerceBackend
dotnet restore
dotnet run --project ECommerce.Api
```

API http://localhost:5080 adresinde açılır. Bağımlılıklara host'tan 3308 (MySQL) ve 6381 (Redis) portlarıyla bağlanacak şekilde bağlantı dizesini ayarlayın.

### Kod stili

```bash
cd ECommerceBackend
dotnet format --verify-no-changes
```

`TreatWarningsAsErrors=true` ve `AnalysisLevel=latest-recommended` aktiftir — derleyici uyarıları build'i kırar. Bilinçli olarak devre dışı bırakılan analyzer kuralları gerekçeleriyle [.editorconfig](ECommerceBackend/.editorconfig)'te listelenmiştir.
