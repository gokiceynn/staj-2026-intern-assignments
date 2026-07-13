import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabından çıkış yapmak istiyor musun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  void _openThemeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final current = ref.watch(themeControllerProvider);
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (mode, label, icon) in const [
                  (ThemeMode.system, 'Sistem', Icons.brightness_auto),
                  (ThemeMode.light, 'Açık', Icons.light_mode_outlined),
                  (ThemeMode.dark, 'Koyu', Icons.dark_mode_outlined),
                ])
                  ListTile(
                    leading: Icon(icon),
                    title: Text(label),
                    trailing: current == mode
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(themeControllerProvider.notifier).set(mode);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hesabım')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Misafir olarak geziyorsun',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Siparişlerini görmek ve hızlı ödeme için giriş yap.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/login'),
                            child: const Text('Giriş Yap'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/register'),
                            child: const Text('Üye Ol'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        user.name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (user != null) ...[
            _MenuTile(
              icon: Icons.receipt_long_outlined,
              title: 'Siparişlerim',
              onTap: () => context.push('/orders'),
            ),
            _MenuTile(
              icon: Icons.location_on_outlined,
              title: 'Adreslerim',
              onTap: () => context.push('/addresses'),
            ),
          ],
          _MenuTile(
            icon: Icons.favorite_border,
            title: 'Favorilerim',
            onTap: () => context.go('/favorites'),
          ),
          if (user?.isAdmin ?? false)
            _MenuTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Admin Paneli',
              iconColor: AppColors.secondary,
              onTap: () => context.push('/admin'),
            ),
          _MenuTile(
            icon: Icons.palette_outlined,
            title: 'Tema',
            subtitle: switch (themeMode) {
              ThemeMode.system => 'Sistem',
              ThemeMode.light => 'Açık',
              ThemeMode.dark => 'Koyu',
            },
            onTap: () => _openThemeSheet(context, ref),
          ),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'Hakkında',
            subtitle: '${AppConfig.appName} v1.0.0 · VB10 Staj 2026',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConfig.appName,
              applicationVersion: '1.0.0',
              applicationLegalese:
                  'VB10 Staj 2026 E-Ticaret projesi mobil uygulaması.\n'
                  'Flutter + Riverpod + Clean Architecture.',
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.logout,
              title: 'Çıkış Yap',
              iconColor: AppColors.danger,
              titleColor: AppColors.danger,
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.primary),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
