import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../providers/order_providers.dart';
import '../widgets/order_status_ui.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Siparişlerim')),
      body: state.when(
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Henüz siparişin yok',
              message: 'İlk siparişini verdiğinde burada görünecek.',
              actionLabel: 'Alışverişe Başla',
              onAction: () => context.go('/home'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final order = orders[i];
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/orders/${order.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              OrderStatusChip(status: order.status),
                              const Spacer(),
                              Text(
                                Formatters.date(order.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final item in order.items.take(3))
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: AppNetworkImage(
                                    url: item.imageUrl,
                                    width: 44,
                                    height: 44,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              if (order.items.length > 3)
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${order.items.length - 3}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Sipariş No: ${order.id} · ${order.totalQuantity} ürün',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Text(
                                Formatters.price(order.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.message : 'Siparişler yüklenemedi.',
          onRetry: () => ref.invalidate(myOrdersProvider),
        ),
      ),
    );
  }
}
