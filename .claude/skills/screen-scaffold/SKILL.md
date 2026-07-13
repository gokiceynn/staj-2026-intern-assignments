---
name: screen-scaffold
description: VBShop mobil (mobile/) projesine yeni bir feature veya ekran iskeleti ekler — Clean Architecture katmanları (domain/data/presentation), Riverpod provider'ları, go_router rotası ve boş/yükleniyor/hata durumlarıyla birlikte. "Yeni ekran", "yeni feature", "ekran iskeleti" taleplerinde kullan.
---

# screen-scaffold — VBShop Yeni Feature/Ekran İskeleti

`mobile/` Flutter projesine yeni bir feature eklerken projedeki yerleşik desenleri
birebir takip et. Referans (örnek) feature: `mobile/lib/features/catalog/`.

## Adımlar

1. **Domain** — `features/<feature>/domain/`
   - `entities/<isim>.dart`: `Equatable` türeyen saf Dart sınıfı. Türetilmiş
     alanları getter olarak ekle (örn. `Product.discountPercent`).
   - `repositories/<feature>_repository.dart`: `abstract interface class`,
     yalnızca entity tipleri kullanır.

2. **Data** — `features/<feature>/data/`
   - `models/<isim>_model.dart`: entity'yi **extend eden** `@JsonSerializable`
     model (`part '<isim>_model.g.dart';`). Liste tipli alan gerekiyorsa
     `OrderModel.items` desenine bak (field gölgeleme). Sonra:
     `dart run build_runner build`
   - `datasources/<feature>_mock_data_source.dart`: `MockDatabase` üzerinden
     çalışır; `AppConfig.mockLatency` ile yapay gecikme ekle.
   - `datasources/<feature>_remote_data_source.dart`: Dio çağrıları; endpoint'i
     önce `core/network/api_endpoints.dart`'a ekle, hataları
     `DioClient.mapError` ile sar. (Sözleşme yayınlanmadıysa bu dosyayı atla ve
     repo impl'e `NOT (contract-first)` yorumu bırak.)
   - `repositories/<feature>_repository_impl.dart`: `AppConfig.useMock`
     bayrağına göre mock/remote seçer.

3. **Presentation** — `features/<feature>/presentation/`
   - `providers/<feature>_providers.dart`:
     - repo provider'ı `core/di/core_providers.dart`'taki bağımlılıklarla kur,
     - okuma için `FutureProvider` / `FutureProvider.family`,
     - mutasyonlu durum için `AsyncNotifier` (aksiyon sonrası
       `state = AsyncData(...)` + etkilenen provider'lara `ref.invalidate`).
     - Riverpod 3'te family notifier arg'ı **constructor** ile alır
       (bkz. `ProductListController`).
   - `screens/<isim>_screen.dart`: `ConsumerWidget`/`ConsumerStatefulWidget`.
     `state.when(data / loading / error)` üçlüsü ZORUNLU:
     - boş liste → `EmptyState` (ikon + başlık + aksiyon),
     - yükleniyor → `AppLoader` veya `SkeletonBox`/`ProductGridSkeleton`,
     - hata → `ErrorView(onRetry: () => ref.invalidate(...))`.

4. **Rota** — `core/router/app_router.dart`
   - Tam ekran sayfa → shell dışına `GoRoute`; sekme → ilgili
     `StatefulShellBranch`.
   - Giriş gerektiriyorsa yolu `_protectedPrefixes`'e ekle.

5. **Kontrol listesi**
   - [ ] Metinler Türkçe, para `Formatters.price`, tarih `Formatters.date`
   - [ ] Renkler `AppColors` / `Theme.of(context).colorScheme` (koyu tema uyumu)
   - [ ] `flutter analyze` temiz, iş kuralı varsa `test/` altına unit test
   - [ ] Hata mesajları `AppException.message` üzerinden SnackBar ile
