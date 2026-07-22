import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_store.dart';
import '../models/user_model.dart';

/// Gerçek API auth uçları (v1.3).
/// `POST /auth/login` → `data`: token alanları + `account` (eski taslaklarda `user`).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._tokenStore);

  final DioClient _client;
  final TokenStore _tokenStore;

  Future<UserModel?> restoreSession() async {
    final token = await _tokenStore.readAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.me,
      );
      return UserModel.fromJson(response.data!);
    } catch (e) {
      final mapped = DioClient.mapError(e);
      if (mapped is UnauthorizedException) {
        // Token süresi dolmuş — sessizce misafir moduna dön.
        await _tokenStore.clear();
        return null;
      }
      throw mapped;
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return _saveSessionFrom(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      return _saveSessionFrom(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<void> logout() => _tokenStore.clear();

  Future<UserModel> _saveSessionFrom(Map<String, dynamic> data) async {
    final profileJson = data['account'] ?? data['user'];
    final user = UserModel.fromJson(profileJson as Map<String, dynamic>);
    await _tokenStore.saveSession(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      userId: user.id,
    );
    return user;
  }
}
