/// Uygulama genel yapılandırması.
///
/// Backend artık ayakta ve tüm uçlar (auth, katalog, sepet, favoriler,
/// siparişler, adresler, satıcı yönetimi) mobilde uygulandı — varsayılan
/// artık gerçek API. Mock veri kaynağı yalnızca backend'e erişilemeyen
/// (offline demo, UI geliştirme) senaryolar için korunur:
///
/// ```sh
/// flutter run --dart-define=USE_MOCK=true
/// flutter run --dart-define=API_BASE_URL=https://api.ornek.com/api/v1
/// ```
abstract final class AppConfig {
  /// true iken repository'ler MockDatabase'e, false iken Dio ile API'ye gider.
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  /// Android emülatöründe host makine `10.0.2.2` üzerinden erişilir.
  /// Port 5082: `API/docker/test/.env.example` → `API_PORT` (host tarafı;
  /// konteyner içi hep 8080). Lokal `dotnet run` kullanıyorsan 5080'dir —
  /// bu durumda `--dart-define=API_BASE_URL=http://10.0.2.2:5080/api/v1`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5082/api/v1',
  );

  /// Web (Next.js) uygulamasının adresi — yalnızca AI asistanı için kullanılır.
  /// Gemini API key'i istemciye asla gömülmez (güvenlik); mevcut
  /// `/api/ai/chat` sunucu ucu üzerinden proxy'lenir — bkz.
  /// `Web/src/app/api/ai/chat/route.ts`.
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  /// Yerel test ortamındaki Mailpit'in (sahte SMTP yakalayıcı) HTTP API
  /// adresi. `USE_MOCK=false` iken OTP kodlarını gerçek e-posta yerine
  /// buradan okuyup bildirim + otomatik doldurma yapmak için kullanılır
  /// (bkz. `core/dev/dev_otp_watcher.dart`). Sadece Android emülatöründe
  /// varsayılan olarak doğru çalışır (`10.0.2.2`); masaüstü/web'de
  /// `--dart-define=MAILPIT_BASE_URL=http://localhost:8026` gerekir.
  static const String mailpitBaseUrl = String.fromEnvironment(
    'MAILPIT_BASE_URL',
    defaultValue: 'http://10.0.2.2:8026',
  );

  static const String appName = 'VBShop';

  /// Mock veri kaynağının ağ gecikmesi simülasyonu — loading/skeleton
  /// durumlarının gerçekçi görünmesi için.
  static const Duration mockLatency = Duration(milliseconds: 450);

  /// Sepette bu tutarın üzerinde kargo bedava.
  static const double freeShippingThreshold = 500;

  /// Standart kargo ücreti.
  static const double shippingFee = 39.99;
}
