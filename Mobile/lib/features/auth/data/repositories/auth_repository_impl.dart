import '../../../../core/config/app_config.dart';
import '../../domain/entities/register_outcome.dart';
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
  Future<RegisterOutcome> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async =>
      AppConfig.useMock
          ? RegisterVerified(
              await _mock.register(
                name: name,
                email: email,
                password: password,
                phone: phone,
              ),
            )
          : _remote.register(
              name: name,
              email: email,
              password: password,
              phone: phone,
            );

  @override
  Future<User> verifyEmail({required String sessionId, required String code}) =>
      AppConfig.useMock
          ? _mock.verifyEmail(sessionId: sessionId, code: code)
          : _remote.verifyEmail(sessionId: sessionId, code: code);

  @override
  Future<String> resendEmailCode(String email) => AppConfig.useMock
      ? _mock.resendEmailCode(email)
      : _remote.resendEmailCode(email);

  @override
  Future<String> forgotPassword(String email) => AppConfig.useMock
      ? _mock.forgotPassword(email)
      : _remote.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String sessionId,
    required String code,
    required String newPassword,
  }) =>
      AppConfig.useMock
          ? _mock.resetPassword(
              sessionId: sessionId,
              code: code,
              newPassword: newPassword,
            )
          : _remote.resetPassword(
              sessionId: sessionId,
              code: code,
              newPassword: newPassword,
            );

  @override
  Future<User> updateProfile({required String name, required String phone}) =>
      AppConfig.useMock
          ? _mock.updateProfile(name: name, phone: phone)
          : _remote.updateProfile(name: name, phone: phone);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      AppConfig.useMock
          ? _mock.changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            )
          : _remote.changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            );

  @override
  Future<void> deleteAccount({required String password}) => AppConfig.useMock
      ? _mock.deleteAccount(password: password)
      : _remote.deleteAccount(password: password);

  @override
  Future<void> logout() =>
      AppConfig.useMock ? _mock.logout() : _remote.logout();
}
