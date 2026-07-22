import 'user.dart';

/// Kayıt sonucu iki farklı biçimde gelebilir:
/// - Mock modda kayıt hemen doğrulanır ve oturum açılır ([RegisterVerified]).
/// - Gerçek API'de backend e-posta doğrulama kodu ister
///   ([RegisterPendingVerification]) — oturum yalnızca `verifyEmail` sonrası açılır.
sealed class RegisterOutcome {
  const RegisterOutcome();
}

class RegisterVerified extends RegisterOutcome {
  const RegisterVerified(this.user);

  final User user;
}

class RegisterPendingVerification extends RegisterOutcome {
  const RegisterPendingVerification({
    required this.sessionId,
    required this.email,
  });

  final String sessionId;
  final String email;
}
