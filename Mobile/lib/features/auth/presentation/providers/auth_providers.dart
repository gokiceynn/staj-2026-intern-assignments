import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/datasources/auth_mock_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
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

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      state = AsyncData(user);
    } catch (_) {
      state = const AsyncData(null);
      rethrow;
    }
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
