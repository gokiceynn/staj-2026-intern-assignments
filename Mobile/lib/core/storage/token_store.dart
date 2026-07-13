import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Access/refresh token'ları platformun güvenli deposunda tutar
/// (Android Keystore, iOS Keychain, Windows DPAPI).
///
/// Token'lar asla SharedPreferences gibi düz metin depolara yazılmaz —
/// bkz. ödev 2026 standartları: "token'ı güvenli sakla (secure storage)".
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<String?> readUserId() => _storage.read(key: _kUserId);

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
    await _storage.write(key: _kUserId, value: userId);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUserId);
  }
}
