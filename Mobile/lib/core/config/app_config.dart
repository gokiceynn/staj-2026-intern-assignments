/// Uygulama genel yapılandırması.
///
/// Mobil ekip, backend API sözleşmesi (OpenAPI) yayınlanana kadar mock veri
/// kaynağıyla paralel ilerler (bkz. ödev dokümanı: "sözleşme önce gelir").
/// Backend hazır olduğunda kod değişikliği GEREKMEDEN gerçek API'ye geçilir:
///
/// ```sh
/// flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.ornek.com/api/v1
/// ```
abstract final class AppConfig {
  /// true iken repository'ler MockDatabase'e, false iken Dio ile API'ye gider.
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// Android emülatöründe host makine `10.0.2.2` üzerinden erişilir.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api/v1',
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
