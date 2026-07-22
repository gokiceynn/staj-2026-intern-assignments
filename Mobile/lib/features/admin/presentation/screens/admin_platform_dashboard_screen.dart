import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../providers/admin_platform_providers.dart';

/// Gerçek platform admin ekranı — `AdminController` (salt-okunur genel
/// denetim: kullanıcılar, satıcılar, platform istatistikleri). Mağaza
/// yönetiminden (`AdminDashboardScreen`, satıcı rolüne özel) tamamen ayrı.
class AdminPlatformDashboardScreen extends ConsumerWidget {
  const AdminPlatformDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(platformStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Paneli')),
      body: state.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(platformStatsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.7,
                children: [
                  _StatCard(
                    icon: Icons.people_outline,
                    label: 'Toplam Kullanıcı',
                    value: '${stats.userCount}',
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    icon: Icons.person_outline,
                    label: 'Müşteri',
                    value: '${stats.customerCount}',
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    icon: Icons.storefront_outlined,
                    label: 'Satıcı',
                    value: '${stats.sellerCount}',
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Aktif Ürün',
                    value: '${stats.activeProductCount}',
                    color: AppColors.success,
                  ),
                  _StatCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Sipariş',
                    value: '${stats.orderCount}',
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    icon: Icons.payments_outlined,
                    label: 'Toplam Ciro',
                    value: Formatters.price(stats.grossSalesAmount),
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.people_outline, color: AppColors.primary),
                  title: const Text(
                    'Kullanıcılar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Tüm platform kullanıcılarını görüntüle',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin-platform/users'),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Satıcılar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Kayıtlı mağazaları görüntüle',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin-platform/sellers'),
                ),
              ),
            ],
          ),
        ),
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: 'İstatistikler yüklenemedi.',
          onRetry: () => ref.invalidate(platformStatsProvider),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
