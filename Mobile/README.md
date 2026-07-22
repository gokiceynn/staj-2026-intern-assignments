# 📱 VBShop - E-Ticaret Mobil Uygulaması 

> **VB10 Staj 2026 · E-Ticaret Ana Projesi · Mobil Teslimatı**
> Uçtan uca e-ticaret mobil uygulaması. API sözleşmesi: [`Docs/ecommerce_api_contract_v1.3.md`](../Docs/ecommerce_api_contract_v1.3.md)
> Flutter · Riverpod · go_router · Dio · Clean Architecture

---

## Ekranlar ve Özellikler

| Alan | Özellikler |
|---|---|
| 🏠 Ana Sayfa | Otomatik kayan kampanya banner'ları, kategori şeridi, ⚡ Süper Fırsatlar rayı, Öne Çıkanlar, En Beğenilenler grid'i, pull-to-refresh |
| 🔍 Arama & Filtre | Arama geçmişi (kalıcı), popüler aramalar, Türkçe karaktere duyarsız arama, fiyat/puan/stok filtreleri, 6 sıralama seçeneği, sonsuz kaydırma (sayfalama) |
| 📦 Ürün Detay | Görsel galerisi, indirim/kargo/stok rozetleri, satıcı bilgisi, açıklama, **yorumlar + yorum yazma**, benzer ürünler |
| 🛒 Sepet | Adet güncelleme, stok doğrulama, **kupon kodları** (`VB10`, `HOSGELDIN50`), **kargo bedava ilerleme çubuğu** (500 TL eşiği), tutar özeti |
| 💳 Checkout | 3 adımlı akış: adres seçimi → kart formu (maskeleme + doğrulama, **ödeme simülasyonu**) → özet & onay; sipariş sonrası stok düşer |
| 🧾 Siparişler | Sipariş geçmişi, sipariş detayı, **durum takip zaman çizelgesi** (Onay Bekliyor → Hazırlanıyor → Kargoda → Teslim) |
| ❤️ Favoriler | Misafir dahil herkes için cihaz-yerel favoriler, her yerden kalp ile ekle/çıkar |
| 👤 Hesap | Login/Register (demo hesap kısayolları), misafir modu, adres defteri (CRUD), **açık/koyu tema**, güvenli çıkış |
| 🛠️ **Admin Paneli** | Rol bazlı erişim; dashboard (ciro, sipariş, müşteri, stok istatistikleri), **ürün CRUD**, **sipariş durumu yönetimi** |

**Edge-case'ler bilinçli tasarlandı:** boş durumlar, skeleton yükleme, hata + tekrar dene, stok tükendi, "Son X ürün!" uyarısı, geçersiz/eşik altı kupon, boş sepetle checkout engeli.

## Demo Hesaplar & Kuponlar

| Rol | E-posta | Şifre |
|---|---|---|
| Müşteri | `demo@vbshop.com` | `demo123` |
| **Admin** | `admin@vbshop.com` | `admin123` |

Kuponlar: `VB10` (%10) · `HOSGELDIN50` (300 TL üzeri 50 TL). Kargo 500 TL üzeri bedava.

## Neden Bu Teknolojiler?

- **Flutter:** Tek kod tabanıyla iOS + Android (bonus: web/masaüstü önizleme). Ekipte tek mobilci olduğum için iki native kod tabanı sürdürülemezdi; Flutter'ın widget sistemi tasarım ekibinin token'larını birebir uygulamayı kolaylaştırıyor.
- **Riverpod 3:** İş mantığını UI'dan tamamen ayırıyor (controller'lar test edilebilir), derleme zamanı güvenli, `ref.invalidate` ile cache tazeleme deseni sipariş/stok senkronizasyonunu basitleştirdi.
- **go_router:** Deklaratif rota tanımı + `redirect` ile **auth guard** (korumalı sayfalar `/login?redirect=...`'e yönlenir, admin rotaları rol kontrolünden geçer).
- **Dio + json_serializable:** Tipli modeller ve interceptor'lı ağ katmanı; token otomatik eklenir, hatalar RFC 9457 Problem Details formatına göre kullanıcı dostu mesajlara çevrilir.
- **flutter_secure_storage:** Token'lar düz metin değil, platformun güvenli deposunda (Keystore/Keychain).

## Mimari

Clean Architecture - her feature üç katman:

```
lib/
├── core/                  # tema, router, Dio, hata tipleri, MockDatabase, ortak widget'lar
└── features/<feature>/
    ├── domain/            # entity'ler + repository SÖZLEŞMELERİ (saf Dart)
    ├── data/              # tipli modeller (json_serializable), mock + remote datasource, repo impl
    └── presentation/      # Riverpod controller/provider + ekranlar (UI "aptal")
```

Feature'lar: `auth`, `catalog`, `cart`, `favorites`, `orders` (checkout dahil), `profile`, `admin`, `shell`.

### Sözleşme-Öncelikli Çalışma (Backend'i Beklemeden)

Ödev gereği backend OpenAPI sözleşmesini yayınlayana kadar mock ile paralel ilerledik:

- **`MockDatabase`** = sahte sunucu: seed JSON'dan yüklenir, tüm mutasyonlar (sepet, sipariş, admin düzenlemeleri) `SharedPreferences`'a kalıcı yazılır. Uygulama kapansa da durum korunur.
- Beklenen endpoint haritası [`lib/core/network/api_endpoints.dart`](lib/core/network/api_endpoints.dart) dosyasında; **auth + katalog** için gerçek Dio remote datasource'ları şimdiden hazır.
- Geçiş tek bayrak, kod değişikliği yok:

```sh
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.ornek.com/api/v1
```

**Yol haritası:** sözleşme netleşince `cart/orders/profile/admin` remote datasource'ları aynı desenle eklenecek (repo impl'lerdeki `NOT (contract-first)` yorumlarına bakın). Favoriler bilinçli olarak cihaz-yerel (misafir desteği + offline).

## Kurulum & Çalıştırma

```sh
cd mobile
flutter pub get
dart run build_runner build          # json_serializable üretimi (repo'da hazır gelir)
flutter run                          # bağlı cihaz/emülatör (Android/iOS)
flutter run -d chrome                # hızlı önizleme (web)
flutter run -d windows               # masaüstü önizleme
```

> Ürün görselleri `picsum.photos`'tan geldiği için emülatörde internet gerekir.

### Testler

```sh
flutter test                                        # 27 unit test
flutter test -d windows integration_test            # uçtan uca E2E (masaüstünde)
```

- **Unit (27):** sepet toplamları, kupon kuralları (eşik/clamp/kargo etkileşimi), ürün filtreleme-sıralama-sayfalama, auth kuralları, sipariş akışı (stok düşümü), admin ürün silme yan etkileri.
- **Integration (E2E):** kritik akışın tamamı gerçek cihazda — `arama → ürün detayı → sepete ekleme → kupon → login guard → 3 adımlı checkout → sipariş oluşturma → sipariş geçmişi`. QA ekibinin Maestro akışlarına temel oluşturur; `-d <android-cihaz-id>` ile emülatörde de çalışır.

## Ekran Görüntüleri

| Açık Tema | Koyu Tema |
|---|---|
| ![Ana sayfa açık tema](screenshots/home_light.png) | ![Ana sayfa koyu tema](screenshots/home_dark.png) |

_(Masaüstü önizlemesinden; emülatör görüntüleri demo videosuyla birlikte eklenecek.)_

## Skill / Agent (2026 zorunlu hedefi)

Geliştirme sırasında tekrar eden "yeni ekran açma" işi `/screen-scaffold` skill'ine dönüştürüldü — bkz. [`SKILLS.md`](SKILLS.md).
