import '../../../../core/config/app_config.dart';
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
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    final user = _db.register(name: name, email: email, password: password);
    await _saveFakeSession(user.id);
    return user;
  }

  Future<void> logout() => _tokenStore.clear();

  Future<void> _saveFakeSession(String userId) => _tokenStore.saveSession(
        accessToken: 'mock-access-$userId',
        refreshToken: 'mock-refresh-$userId',
        userId: userId,
      );
}
