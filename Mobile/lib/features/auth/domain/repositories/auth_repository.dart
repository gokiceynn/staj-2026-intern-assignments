import '../entities/register_outcome.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  /// Uygulama açılışında kayıtlı token varsa oturumu geri yükler.
  Future<User?> restoreSession();

  Future<User> login({required String email, required String password});

  Future<RegisterOutcome> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<User> verifyEmail({required String sessionId, required String code});

  Future<String> resendEmailCode(String email);

  Future<String> forgotPassword(String email);

  Future<void> resetPassword({
    required String sessionId,
    required String code,
    required String newPassword,
  });

  /// `name` ilk boşluğa göre ad/soyada bölünür (bkz. [register]).
  Future<User> updateProfile({required String name, required String phone});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount({required String password});

  Future<void> logout();
}
