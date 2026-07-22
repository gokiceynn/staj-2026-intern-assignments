import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../../core/storage/token_store.dart';
import '../models/user_model.dart';

/// Mock auth: kullanıcıları [MockDatabase]'ten doğrular, sahte token üretir.
/// Gerçek API'deki gibi token secure storage'a yazılır ki geçiş sorunsuz olsun.
class AuthMockDataSource {
  AuthMockDataSource(this._db, this._tokenStore);

  final MockDatabase _db;
  final TokenStore _tokenStore;

  Future<UserModel?> restoreSession() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    final userId = await _tokenStore.readUserId();
    if (userId == null) return null;
    return _db.userById(userId);
  }

  Future<UserModel> login(String email, String password) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    final user = _db.login(email, password);
    await _saveFakeSession(user.id);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    final user = _db.register(name: name, email: email, password: password);
    await _saveFakeSession(user.id);
    return user;
  }

  Future<void> logout() => _tokenStore.clear();

  /// Mock modda e-posta doğrulaması yoktur; bu metotlar gerçek API
  /// arayüzünü tamamlamak için var ama register() zaten anında oturum açtığı
  /// için çağrılmaları beklenmez.
  Future<UserModel> verifyEmail({
    required String sessionId,
    required String code,
  }) async =>
      throw const ValidationException('Mock modda e-posta doğrulama yok.');

  Future<String> resendEmailCode(String email) async => 'mock-session';

  Future<String> forgotPassword(String email) async => 'mock-session';

  Future<void> resetPassword({
    required String sessionId,
    required String code,
    required String newPassword,
  }) async {}

  /// Mock modda profil değişikliği kalıcı değildir (`MockDatabase`
  /// düzenlemeyi desteklemiyor) — mevcut kullanıcı olduğu gibi döner.
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
  }) async {
    final userId = await _tokenStore.readUserId();
    if (userId == null) throw const UnauthorizedException();
    return _db.userById(userId) ??
        (throw const NotFoundException('Kullanıcı bulunamadı.'));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  Future<void> deleteAccount({required String password}) => logout();

  Future<void> _saveFakeSession(String userId) => _tokenStore.saveSession(
        accessToken: 'mock-access-$userId',
        refreshToken: 'mock-refresh-$userId',
        userId: userId,
      );
}
