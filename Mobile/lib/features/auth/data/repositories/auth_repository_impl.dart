import '../../../../core/config/app_config.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_mock_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// `USE_MOCK` bayrağına göre mock veya gerçek API'ye yönlendirir.
/// Üst katmanlar (provider/ekran) hangi kaynağın kullanıldığını bilmez.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthMockDataSource mock,
    required AuthRemoteDataSource remote,
  })  : _mock = mock,
        _remote = remote;

  final AuthMockDataSource _mock;
  final AuthRemoteDataSource _remote;

  @override
  Future<User?> restoreSession() =>
      AppConfig.useMock ? _mock.restoreSession() : _remote.restoreSession();

  @override
  Future<User> login({required String email, required String password}) =>
      AppConfig.useMock
          ? _mock.login(email, password)
          : _remote.login(email, password);

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) =>
      AppConfig.useMock
          ? _mock.register(name: name, email: email, password: password)
          : _remote.register(name: name, email: email, password: password);

  @override
  Future<void> logout() =>
      AppConfig.useMock ? _mock.logout() : _remote.logout();
}
