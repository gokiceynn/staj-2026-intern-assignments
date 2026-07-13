import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

/// Açılış ekranı: kayıtlı oturumu geri yükler, ardından ana sayfaya geçer.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    try {
      // Güvenlik ağı: oturum geri yükleme hiçbir koşulda açılışı kilitlemesin.
      await ref
          .read(authControllerProvider.future)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      // Oturum geri yüklenemedi — misafir olarak devam.
    }
    // Logo en az 900 ms görünsün (marka anı + geçiş yumuşaklığı).
    final elapsed = DateTime.now().difference(started);
    final remaining = const Duration(milliseconds: 900) - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppConfig.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aradığın her şey burada',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
