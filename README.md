# VBShop — E-Ticaret Platformu

VBShop, staj 2026 ana proje kapsamında geliştirilmiş uçtan uca bir e-ticaret uygulamasıdır. Ürün listeleme, arama ve filtreleme, ürün detayı, sepet, favoriler, ödeme simülasyonu, sipariş geçmişi ve kullanıcı hesabı akışlarını **web**, **mobil** ve **backend API** üzerinden aynı veri kaynağıyla sunar.

Monorepo yapısı:

| Klasör | Açıklama |
|--------|----------|
| [`API/`](API/) | .NET 9 marketplace backend (MySQL, Redis, Docker) |
| [`Web/`](Web/) | Next.js 15 B2C web arayüzü |
| [`Mobile/`](Mobile/) | Flutter mobil uygulama (iOS / Android / web önizleme) |
| [`Docs/`](Docs/) | Paylaşılan API sözleşmesi (v1.3) |

---

## Demo Videosu

Uçtan uca akışın canlı gösterimi:

**https://youtu.be/W3-WpAKcIH0**

---

## Proje Özeti

Geçen dönem tek alana odaklanan ödevlerden farklı olarak bu projede gerçek bir ürün mantığıyla çalıştık: tasarım kararları, API sözleşmesi, backend implementasyonu, web ve mobil istemciler, testler ve entegrasyon aynı repo içinde bir araya geldi.

**Kritik akış (çalışır durumda):** ürün gez → sepete ekle → checkout → ödeme simülasyonu → sipariş oluşturma

Web ve mobil **mock veriyle değil**, canlı backend API (`/api/v1`) üzerinden çalışır.

---

## Çalışma Modeli

### Sözleşme önce gelir

Backend iş mantığına geçmeden önce ortak API sözleşmesi yazıldı ve repoda yayınlandı:

- [`Docs/ecommerce_api_contract_v1.3.md`](Docs/ecommerce_api_contract_v1.3.md)

Web ve mobil ekipler bu sözleşmeye göre paralel ilerledi; backend hazır olmadığı dönemde mock katmanları geliştirmeyi hızlandırdı, entegrasyon günü gerçek endpoint'lere geçildi.

### Haftalık ritim

| Hafta | Odak |
|-------|------|
| 1 | API sözleşmesi, auth, ürün listesi ve detay, tasarım token'ları |
| 2 | Sepet, checkout, favoriler, entegrasyon, testler, demo |

### Definition of Done

Bir özellik tamam sayılır: kod merge edildi, ilgili testler yeşil, demo ortamında gösterilebilir.

---

## Backend (`API/`)

Çok satıcılı (marketplace) e-ticaret API'si.

**Teknolojiler:** .NET 9 · ASP.NET Core · EF Core · MySQL 8.4 · Redis · Clean Architecture · Docker

**Neden bu stack?** Ekip .NET deneyimine sahipti; EF Core migration'ları, JWT tabanlı auth ve Docker ile tek komutla ayağa kalkan ortam, staj süresinde hızlı iterasyon sağladı. Redis ile token iptali ve rate limiting production'a yakın güvenlik davranışı verdi.

### Kapsam

- **Auth:** kayıt, e-posta OTP doğrulama, giriş, refresh token rotasyonu, şifre sıfırlama
- **Katalog:** ürün listeleme (sayfalama, filtre, arama), kategori, yorumlar
- **Sepet & favoriler**
- **Siparişler:** checkout (idempotency key), ödeme simülasyonu, sipariş geçmişi, iptal
- **Profil & adresler**
- **Satıcı & admin** panelleri (ürün CRUD, sipariş paket yönetimi)

### Dokümantasyon & çalıştırma

- Swagger UI: `http://127.0.0.1:5082/swagger` (test stack)
- Detaylı kurulum: [`API/README.md`](API/README.md)

```bash
cd API/docker/test
cp .env.example .env
# .env içindeki secret alanlarını doldurun (README'de anlatılıyor)
docker compose up -d --build
```

Mailpit ile OTP testi: `http://127.0.0.1:8026`

### Testler

Unit, architecture, contract ve integration testleri (`dotnet test`). Integration testler Testcontainers ile kendi MySQL/Redis konteynerlerini açar.

---

## Web (`Web/`)

B2C e-ticaret web arayüzü.

**Teknolojiler:** Next.js 15 · TypeScript · Tailwind CSS 4 · TanStack Query · React Hook Form · Zod

**Neden Next.js?** App Router ile sunucu bileşenleri + BFF route handler'ları aynı projede; httpOnly cookie ile JWT yönetimi tarayıcıya sızmıyor. TanStack Query sunucu durumu, cache ve loading/error durumlarını standartlaştırdı.

### Tamamlanan akışlar

- Ana sayfa (kampanya, kategori şeridi, ürün bölümleri — En Yeni, Popüler, En Beğenilenler)
- Ürün listesi: arama, filtre, sıralama, URL query senkronu
- Ürün detay, sepete ekleme, favoriler
- Auth: kayıt → OTP → giriş, şifre sıfırlama
- Sepet, checkout, sipariş geçmişi ve detay
- Profil, adres yönetimi
- Satıcı paneli: ürün ekleme (fotoğraf yükleme), listeleme
- **AI asistan:** Google Gemini tabanlı alışveriş yardımcısı (sunucu tarafı, key tarayıcıya gitmez)

### Mimari notlar

- BFF: `/api/bff/*` ve `/api/auth/*` → backend v1.3
- Token: httpOnly cookie + otomatik refresh
- CI: lint, typecheck, Vitest, build, Playwright E2E

Detay: [`Web/Readme.md`](Web/Readme.md) · [`Web/docs/FRONTEND_HANDOFF.md`](Web/docs/FRONTEND_HANDOFF.md)

```bash
cd Web
cp .env.example .env.local
npm install
npm run dev
# http://localhost:3000
```

---

## Mobil (`Mobile/`)

iOS ve Android için tek kod tabanı; Flutter web ile tarayıcıda da test edilebilir.

**Teknolojiler:** Flutter · Riverpod 3 · go_router · Dio · json_serializable · Clean Architecture

**Neden Flutter?** Tek mobil geliştiriciyle iki native kod tabanı sürdürmek mümkün değildi; widget sistemi tasarım token'larını uygulamayı kolaylaştırdı, web derlemesiyle hızlı önizleme sağlandı.

### Ekranlar

Ana sayfa, arama/filtre, ürün detay (yorum yazma), sepet (kupon, kargo eşiği), 3 adımlı checkout, sipariş geçmişi, favoriler, profil/adres, satıcı admin paneli, AI asistan, karşılama kampanyası.

Boş durum, skeleton, hata + tekrar dene ve stok uyarıları bilinçli ele alındı.

Detay: [`Mobile/README.md`](Mobile/README.md)

```bash
cd Mobile
flutter pub get
flutter run                          # emülatör / cihaz
flutter run -d web-server --web-port=8080 --web-hostname=localhost   # tarayıcı
# http://localhost:8080
```

API adresi varsayılan: `http://localhost:5082/api/v1` (web derlemesinde).

---

## Tasarım

Turuncu marka rengi (`#FF6000`), açık/koyu tema, ProductCard, badge'ler, boş/yükleniyor/hata durumları web ve mobilde ortak dilde uygulandı. Kampanya odaklı ana sayfa, kategori şeritleri ve mobil yatay ürün rayları tasarım kararlarının somut çıktısıdır.

---

## Test & Kalite

| Katman | Araç |
|--------|------|
| Backend | xUnit, architecture test, Testcontainers integration |
| Web | Vitest (birim), Playwright (E2E), GitHub Actions CI |
| Mobil | 27 unit test, integration E2E (mock mod) |

Web test planı: [`Web/docs/TEST_PLAN.md`](Web/docs/TEST_PLAN.md)

---

## Skill / Agent (Geliştirme Araçları)

Tekrarlayan geliştirme işleri skill dosyalarına dönüştürüldü:

| Skill | Takım | Amaç |
|-------|-------|------|
| `/home-section` | Web | Ana sayfaya yeni ürün bölümü ekleme kalıbı |
| `/screen-scaffold` | Mobil | Clean Architecture feature/ekran iskeleti |

Belgeler: [`Web/SKILLS.md`](Web/SKILLS.md) · [`Mobile/SKILLS.md`](Mobile/SKILLS.md)

---

## Hızlı Başlangıç (Tüm Stack)

**Gereksinimler:** Docker · Node.js 22+ · Flutter SDK

```bash
# 1) Backend
cd API/docker/test && docker compose up -d --build

# 2) Web (yeni terminal)
cd Web && cp .env.example .env.local && npm install && npm run dev

# 3) Mobil (yeni terminal, isteğe bağlı)
cd Mobile && flutter pub get && flutter run -d web-server --web-port=8080 --web-hostname=localhost
```

| Servis | Adres |
|--------|-------|
| API Swagger | http://127.0.0.1:5082/swagger |
| Web | http://localhost:3000 |
| Mobil (web) | http://localhost:8080 |
| Mailpit (OTP) | http://127.0.0.1:8026 |

---

## API Sözleşmesi

Tüm istemcilerin ortak referansı:

**[`Docs/ecommerce_api_contract_v1.3.md`](Docs/ecommerce_api_contract_v1.3.md)**

Yanıt zarfı, sayfalama (`?page=&size=`), filtre, JWT auth ve hata kodları bu dokümanda standartlaştırıldı.

---

## Ekran Görüntüleri

Web ana sayfa ve mobil ekranlar demo videosunda gösterilmektedir: **https://youtu.be/W3-WpAKcIH0**

Mobil tema örnekleri: [`Mobile/README.md`](Mobile/README.md) (screenshots klasörü)

---

## Katkıda Bulunanlar

| Rol | Sorumluluk |
|-----|------------|
| Backend | API, Docker, Swagger, testler |
| Web (Frontend) | Next.js arayüz, BFF, AI asistan, CI |
| Mobil | Flutter uygulama, Clean Architecture |
| Tasarım | UI token'ları, ekran dili, kampanya görselleri |
| QA | Test planı, E2E senaryoları |

---

## Lisans & Not

Bu proje VB10 Staj 2026 kapsamında eğitim amaçlı geliştirilmiştir. Production secret'ları repoya commit edilmemelidir; `.env`, `secrets/` ve API key dosyaları `.gitignore` altındadır.
