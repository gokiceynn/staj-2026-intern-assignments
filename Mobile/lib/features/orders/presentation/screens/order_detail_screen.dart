import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../domain/entities/order.dart';
import '../providers/order_providers.dart';
import '../widgets/order_status_ui.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Sipariş Detayı')),
      body: state.when(
        data: (order) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sipariş No: ${order.id}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        OrderStatusChip(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.dateTime(order.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 24),
                    _OrderTimeline(status: order.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Ürünler (${order.totalQuantity})',
              child: Column(
                children: [
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          AppNetworkImage(
                            url: item.imageUrl,
                            width: 48,
                            height: 48,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  '${item.quantity} adet × ${Formatters.price(item.price)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            Formatters.price(item.lineTotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Teslimat Adresi',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.recipientName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(order.addressText,
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Ödeme',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.credit_card, size: 18),
                      const SizedBox(width: 8),
                      Text('**** **** **** ${order.cardLast4}'),
                    ],
                  ),
                  const Divider(height: 20),
                  _row(context, 'Ara Toplam', Formatters.price(order.subtotal)),
                  if (order.couponDiscount > 0)
                    _row(
                      context,
                      'Kupon${order.couponCode == null ? '' : ' (${order.couponCode})'}',
                      '-${Formatters.price(order.couponDiscount)}',
                      color: AppColors.success,
                    ),
                  _row(
                    context,
                    'Kargo',
                    order.shippingFee == 0
                        ? 'Bedava'
                        : Formatters.price(order.shippingFee),
                    color: order.shippingFee == 0 ? AppColors.success : null,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Toplam',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        Formatters.price(order.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.message : 'Sipariş yüklenemedi.',
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

/// Sipariş durumu zaman çizelgesi. İptal edilen siparişte kırmızı bant
/// gösterilir; aksi halde 4 adımlı akış işaretlenir.
class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.status});

  final OrderStatus status;

  static const _flow = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.danger, size: 18),
            SizedBox(width: 8),
            Text(
              'Bu sipariş iptal edildi.',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _flow.indexOf(status);
    return Row(
      children: [
        for (var i = 0; i < _flow.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: i <= currentIndex
                        ? _flow[i].color.withValues(alpha: 0.15)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _flow[i].icon,
                    size: 16,
                    color: i <= currentIndex
                        ? _flow[i].color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _flow[i].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight:
                        i <= currentIndex ? FontWeight.w800 : FontWeight.w400,
                    color: i <= currentIndex
                        ? _flow[i].color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (i < _flow.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: i < currentIndex
                    ? _flow[i + 1].color
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
        ],
      ],
    );
  }
}
