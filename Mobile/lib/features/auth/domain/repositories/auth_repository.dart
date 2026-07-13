import '../entities/user.dart';

abstract interface class AuthRepository {
  /// Uygulama açılışında kayıtlı token varsa oturumu geri yükler.
  Future<User?> restoreSession();

  Future<User> login({required String email, required String password});

  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}
