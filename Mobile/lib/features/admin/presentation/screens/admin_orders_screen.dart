import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/widgets/order_status_ui.dart';
import '../providers/admin_providers.dart';

/// Tüm siparişleri listeler; durum güncelleme menüsü sunar.
class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    Order order,
    OrderStatus status,
  ) async {
    try {
      await ref.read(adminActionsProvider).updateOrderStatus(order.id, status);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${order.id} → ${status.label}'),
          backgroundColor: AppColors.success,
        ),
      );
    } on AppException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sipariş Yönetimi')),
      body: state.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Henüz sipariş yok',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final order = orders[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            OrderStatusChip(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.recipientName} · '
                          '${Formatters.dateTime(order.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${order.totalQuantity} ürün',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                Formatters.price(order.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            PopupMenuButton<OrderStatus>(
                              onSelected: (status) =>
                                  _updateStatus(context, ref, order, status),
                              itemBuilder: (_) => [
                                for (final status in OrderStatus.values)
                                  if (status != order.status)
                                    PopupMenuItem(
                                      value: status,
                                      child: Row(
                                        children: [
                                          Icon(
                                            status.icon,
                                            size: 18,
                                            color: status.color,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(status.label),
                                        ],
                                      ),
                                    ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Durumu Güncelle',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: 'Siparişler yüklenemedi.',
          onRetry: () => ref.invalidate(adminOrdersProvider),
        ),
      ),
    );
  }
}
