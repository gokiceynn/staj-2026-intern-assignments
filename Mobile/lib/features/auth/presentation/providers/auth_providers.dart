import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/datasources/auth_mock_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/register_outcome.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    mock: AuthMockDataSource(
      ref.watch(mockDatabaseProvider),
      ref.watch(tokenStoreProvider),
    ),
    remote: AuthRemoteDataSource(
      ref.watch(dioClientProvider),
      ref.watch(tokenStoreProvider),
    ),
  );
});

/// Oturum durumu. `null` = misafir.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() => ref.watch(authRepositoryProvider).restoreSession();

  /// Başarısızlıkta [AppException] fırlatır — ekran SnackBar gösterir.
  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = AsyncData(user);
    } catch (_) {
      state = const AsyncData(null);
      rethrow;
    }
  }

  /// Mock modda anında oturum açar ([RegisterVerified]); gerçek API'de
  /// e-posta doğrulama kodu beklenir ([RegisterPendingVerification]) —
  /// ekran bu durumda [VerifyEmailScreen]'e yönlendirmelidir.
  Future<RegisterOutcome> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = const AsyncLoading();
    try {
      final outcome = await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
            phone: phone,
          );
      state = AsyncData(outcome is RegisterVerified ? outcome.user : null);
      return outcome;
    } catch (_) {
      state = const AsyncData(null);
      rethrow;
    }
  }

  Future<void> verifyEmail({
    required String sessionId,
    required String code,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .verifyEmail(sessionId: sessionId, code: code);
      state = AsyncData(user);
    } catch (_) {
      state = const AsyncData(null);
      rethrow;
    }
  }

  Future<String> resendEmailCode(String email) =>
      ref.read(authRepositoryProvider).resendEmailCode(email);

  Future<String> forgotPassword(String email) =>
      ref.read(authRepositoryProvider).forgotPassword(email);

  Future<void> resetPassword({
    required String sessionId,
    required String code,
    required String newPassword,
  }) =>
      ref.read(authRepositoryProvider).resetPassword(
            sessionId: sessionId,
            code: code,
            newPassword: newPassword,
          );

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .updateProfile(name: name, phone: phone);
    state = AsyncData(user);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );

  Future<void> deleteAccount(String password) async {
    await ref.read(authRepositoryProvider).deleteAccount(password: password);
    state = const AsyncData(null);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

/// Ekranların kısa yolu: mevcut kullanıcı (misafirse null).
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authControllerProvider).value,
);

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider) != null,
);

final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider)?.isAdmin ?? false,
);
