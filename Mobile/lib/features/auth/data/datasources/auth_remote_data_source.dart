import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_store.dart';
import '../../domain/entities/register_outcome.dart';
import '../models/user_model.dart';

/// Gerçek API auth uçları.
/// `POST /auth/login` → `{accessToken, refreshToken, account}` (`account` =
/// `AccountSummary`: `firstName`/`lastName`/`phoneNumber`, tek `name` yok).
/// `POST /auth/customer/register` → `{sessionId, expiresAt}` — backend
/// e-posta doğrulama kodu zorunlu kılar, token hemen dönmez; oturum ancak
/// `verifyEmail` sonrası açılır (bkz. [RegisterOutcome]).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._tokenStore);

  final DioClient _client;
  final TokenStore _tokenStore;

  Future<UserModel?> restoreSession() async {
    final token = await _tokenStore.readAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.accountMe,
      );
      return UserModel.fromAccountSummary(
        response.data!['account'] as Map<String, dynamic>,
      );
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

  /// `name` alanı ilk boşluğa göre ad/soyada bölünür; backend ikisini de
  /// zorunlu kılar. Kayıt hemen oturum açmaz — dönen `sessionId` ile
  /// [verifyEmail] çağrılmalıdır.
  Future<RegisterOutcome> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final parts = name.trim().split(RegExp(r'\s+'));
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '-';
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.customerRegister,
        data: {
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phone,
        },
      );
      final data = response.data!;
      return RegisterPendingVerification(
        sessionId: data['sessionId'] as String,
        email: email,
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<UserModel> verifyEmail({
    required String sessionId,
    required String code,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.emailVerify,
        data: {'sessionId': sessionId, 'code': code},
      );
      return _saveSessionFrom(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  /// Yeni doğrulama kodu ister; yeni bir `sessionId` döner (eskisi geçersiz olur).
  Future<String> resendEmailCode(String email) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.emailResend,
        data: {'email': email},
      );
      return response.data!['sessionId'] as String;
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  /// Hesap var olsun ya da olmasın 200 döner (enumeration'ı önlemek için);
  /// `sessionId` yalnızca hesap gerçekten varsa `reset-password`'de işe yarar.
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return response.data!['sessionId'] as String;
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<void> resetPassword({
    required String sessionId,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _client.dio.post<void>(
        ApiEndpoints.resetPassword,
        data: {
          'sessionId': sessionId,
          'code': code,
          'newPassword': newPassword,
          'newPasswordConfirm': newPassword,
        },
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<UserModel> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final parts = name.trim().split(RegExp(r'\s+'));
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '-';
      final response = await _client.dio.put<Map<String, dynamic>>(
        ApiEndpoints.accountMe,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phone,
        },
      );
      return UserModel.fromAccountSummary(
        response.data!['account'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.dio.put<void>(
        ApiEndpoints.accountPassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'newPasswordConfirm': newPassword,
        },
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<void> deleteAccount({required String password}) async {
    try {
      await _client.dio.delete<void>(
        ApiEndpoints.deleteCustomerAccount,
        data: {'password': password},
      );
    } catch (e) {
      throw DioClient.mapError(e);
    } finally {
      await _tokenStore.clear();
    }
  }

  Future<void> logout() async {
    try {
      await _client.dio.post<void>(ApiEndpoints.logout);
    } catch (_) {
      // Sunucu tarafı oturum kaydı silinemese bile yerel oturum temizlenir.
    } finally {
      await _tokenStore.clear();
    }
  }

  Future<UserModel> _saveSessionFrom(Map<String, dynamic> data) async {
    final user = UserModel.fromAccountSummary(
      data['account'] as Map<String, dynamic>,
    );
    await _tokenStore.saveSession(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      userId: user.id,
    );
    return user;
  }
}
