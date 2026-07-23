import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/register_outcome.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.redirect});

  final String? redirect;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// Backend `+[1-9][0-9]{7,14}` (E.164) bekler; kullanıcı yerel formatta
/// girer (`5xx...` ya da `05xx...`). Zaten `+` ile başlıyorsa dokunulmaz.
String _toE164(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith('+')) {
    return '+${trimmed.substring(1).replaceAll(RegExp(r'\D'), '')}';
  }
  var digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0')) digits = digits.substring(1);
  return '+90$digits';
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  /// `+90` önceden seçili gelir (Türkiye); kullanıcı isterse üzerine
  /// yazıp farklı bir ülke koduyla değiştirebilir.
  final _phoneController = TextEditingController(text: '+90');
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final outcome = await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _toE164(_phoneController.text),
          );
      if (!mounted) return;
      if (outcome is RegisterPendingVerification) {
        context.push(
          Uri(
            path: '/verify-email',
            queryParameters: {
              'sessionId': outcome.sessionId,
              'email': outcome.email,
              if (widget.redirect != null) 'redirect': widget.redirect!,
            },
          ).toString(),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hesabın oluşturuldu, hoş geldin! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(widget.redirect ?? '/home');
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Üye Ol')),
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
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().length < 3)
                              ? 'Ad soyad gerekli'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        hintText: '+90 5xx xxx xx xx',
                        helperText:
                            'Varsayılan +90 (Türkiye) — farklı bir ülke '
                            'kodu için değiştirebilirsin',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        final e164 = _toE164(value ?? '');
                        return RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(e164)
                            ? null
                            : 'Geçerli bir telefon girin';
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        helperText:
                            'En az 12 karakter; büyük/küçük harf ve rakam içermeli',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (value) {
                        final v = value ?? '';
                        if (v.length < 12) return 'En az 12 karakter olmalı';
                        if (!RegExp(r'[A-Z]').hasMatch(v) ||
                            !RegExp(r'[a-z]').hasMatch(v) ||
                            !RegExp(r'[0-9]').hasMatch(v)) {
                          return 'Büyük/küçük harf ve rakam içermeli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      decoration: const InputDecoration(
                        labelText: 'Şifre (tekrar)',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      onFieldSubmitted: (_) => busy ? null : _submit(),
                      validator: (value) => value != _passwordController.text
                          ? 'Şifreler eşleşmiyor'
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
                          : const Text('Üye Ol'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kayıt kuralları',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Telefon uluslararası formatta olmalı (ör. '
                            '+90 5xx xxx xx xx)\n'
                            '• Şifre en az 12 karakter olmalı, büyük/küçük '
                            'harf ve rakam içermeli',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Üye olarak kullanım koşullarını kabul etmiş olursun.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
