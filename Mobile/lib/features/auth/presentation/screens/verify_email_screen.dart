import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/dev/dev_otp_watcher.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

/// Kayıt sonrası e-postaya gönderilen kodun girildiği ekran.
/// `RegisterPendingVerification` sonucu buraya `sessionId` + `email` taşır.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.sessionId,
    required this.email,
    this.redirect,
  });

  final String sessionId;
  final String email;
  final String? redirect;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  late String _sessionId = widget.sessionId;
  bool _busy = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    // Dev/test kolaylığı: Mailpit'e düşen kodu bulunca bildirim gösterir
    // ve alanı otomatik doldurur (gerçek SMTP'de sessizce devre dışı kalır).
    DevOtpWatcher.start(
      email: widget.email,
      onCode: (code) {
        if (!mounted) return;
        setState(() => _codeController.text = code);
      },
    );
  }

  @override
  void dispose() {
    DevOtpWatcher.stop();
    _codeController.dispose();
    super.dispose();
  }

  void _snack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyEmail(
            sessionId: _sessionId,
            code: _codeController.text.trim(),
          );
      if (!mounted) return;
      _snack('Hesabın doğrulandı, hoş geldin! 🎉', color: AppColors.success);
      context.go(widget.redirect ?? '/home');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(e.message, color: AppColors.danger);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final sessionId = await ref
          .read(authControllerProvider.notifier)
          .resendEmailCode(widget.email);
      if (!mounted) return;
      setState(() => _sessionId = sessionId);
      _snack('Yeni kod gönderildi.', color: AppColors.success);
    } on AppException catch (e) {
      if (!mounted) return;
      _snack(e.message, color: AppColors.danger);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-postanı Doğrula')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.mark_email_read_outlined,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.email} adresine gönderilen kodu gir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Doğrulama Kodu',
                        counterText: '',
                      ),
                      maxLength: 6,
                      onFieldSubmitted: (_) => _busy ? null : _verify(),
                      validator: (value) => (value ?? '').trim().length < 4
                          ? 'Geçerli bir kod girin'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _busy ? null : _verify,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Doğrula'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _resending ? null : _resend,
                      child: Text(
                        _resending ? 'Gönderiliyor...' : 'Kodu tekrar gönder',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
