import 'package:flutter/foundation.dart';

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
  /// Web ve masaüstünde `localhost` kullanılır — tarayıcı `10.0.2.2`'ye erişemez.
  static const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) return _apiBaseUrlFromEnv;
    if (kIsWeb) return 'http://localhost:5082/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5082/api/v1';
    }
    return 'http://localhost:5082/api/v1';
  }

  static const String _webBaseUrlFromEnv = String.fromEnvironment('WEB_BASE_URL');

  static String get webBaseUrl {
    if (_webBaseUrlFromEnv.isNotEmpty) return _webBaseUrlFromEnv;
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const String _mailpitBaseUrlFromEnv =
      String.fromEnvironment('MAILPIT_BASE_URL');

  static String get mailpitBaseUrl {
    if (_mailpitBaseUrlFromEnv.isNotEmpty) return _mailpitBaseUrlFromEnv;
    if (kIsWeb) return 'http://localhost:8026';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8026';
    }
    return 'http://localhost:8026';
  }

  static const String appName = 'VBShop';

  /// Mock veri kaynağının ağ gecikmesi simülasyonu — loading/skeleton
  /// durumlarının gerçekçi görünmesi için.
  static const Duration mockLatency = Duration(milliseconds: 450);

  /// Sepette bu tutarın üzerinde kargo bedava.
  static const double freeShippingThreshold = 500;

  /// Standart kargo ücreti.
  static const double shippingFee = 39.99;
}
