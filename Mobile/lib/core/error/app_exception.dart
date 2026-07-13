/// Uygulama genelinde kullanılan, kullanıcıya gösterilebilir hata tipleri.
///
/// Data katmanı (Dio hataları, mock doğrulamaları) bu tiplere map edilir;
/// presentation katmanı yalnızca [AppException.message] gösterir.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Ağ/sunucu kaynaklı hatalar (timeout, 5xx, bağlantı yok).
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Bağlantı sorunu oluştu. Lütfen tekrar deneyin.',
  ]);
}

/// 401/403 — oturum geçersiz veya yetki yok.
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Bu işlem için giriş yapmalısınız.',
  ]);
}

/// 404 — kayıt bulunamadı.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Aradığınız kayıt bulunamadı.']);
}

/// 400/422 — iş kuralı veya form doğrulama hatası (ör. geçersiz kupon,
/// stok yetersiz, e-posta zaten kayıtlı).
class ValidationException extends AppException {
  const ValidationException(super.message);
}
