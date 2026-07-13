import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/widgets/order_status_ui.dart';
import '../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Paneli')),
      body: state.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminStatsProvider),
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
                    icon: Icons.payments_outlined,
                    label: 'Toplam Ciro',
                    value: Formatters.price(stats.totalRevenue),
                    color: AppColors.success,
                  ),
                  _StatCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Sipariş',
                    value: '${stats.orderCount}',
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Ürün',
                    value: '${stats.productCount}',
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    icon: Icons.people_outline,
                    label: 'Müşteri',
                    value: '${stats.customerCount}',
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    icon: Icons.hourglass_top_rounded,
                    label: 'Bekleyen Sipariş',
                    value: '${stats.pendingCount}',
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    icon: Icons.remove_shopping_cart_outlined,
                    label: 'Tükenen Ürün',
                    value: '${stats.outOfStockCount}',
                    color: AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Sipariş Durumları',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in OrderStatus.values)
                    if ((stats.statusBreakdown[status] ?? 0) > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${status.label}: ${stats.statusBreakdown[status]}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: status.color,
                          ),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Ürün Yönetimi',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Ürün ekle, düzenle, sil',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin/products'),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Sipariş Yönetimi',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Sipariş durumlarını güncelle',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin/orders'),
                ),
              ),
            ],
          ),
        ),
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: 'İstatistikler yüklenemedi.',
          onRetry: () => ref.invalidate(adminStatsProvider),
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
