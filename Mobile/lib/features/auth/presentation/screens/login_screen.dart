import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.redirect});

  /// Giriş sonrası dönülecek yol (ör. korumalı /checkout'tan yönlendirildiyse).
  final String? redirect;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go(widget.redirect ?? '/home');
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    }
  }

  /// Demo hesabıyla tek dokunuşta giriş: alanları doldurur ve gönderir.
  Future<void> _loginAsDemo({required bool admin}) async {
    _emailController.text = admin ? 'admin@vbshop.com' : 'demo@vbshop.com';
    _passwordController.text = admin ? 'admin123' : 'demo123';
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
          tooltip: 'Vazgeç',
        ),
      ),
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
                      Icons.shopping_bag_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Giriş Yap',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Siparişlerin, favorilerin ve daha fazlası için',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'E-posta gerekli';
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Geçerli bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      onFieldSubmitted: (_) => busy ? null : _submit(),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Şifre en az 6 karakter olmalı'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: busy ? null : _submit,
                      child: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Giriş Yap'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => context.push(
                                Uri(
                                  path: '/register',
                                  queryParameters: widget.redirect == null
                                      ? null
                                      : {'redirect': widget.redirect},
                                ).toString(),
                              ),
                      child: const Text('Hesabın yok mu? Üye ol'),
                    ),
                    const Divider(height: 32),
                    Text(
                      'Demo hesaplarıyla tek dokunuşta giriş',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.person_outline, size: 18),
                          label: const Text('Müşteri Girişi'),
                          onPressed:
                              busy ? null : () => _loginAsDemo(admin: false),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 18,
                          ),
                          label: const Text('Admin Girişi'),
                          onPressed:
                              busy ? null : () => _loginAsDemo(admin: true),
                        ),
                      ],
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
