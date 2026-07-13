import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/order.dart';

extension OrderStatusUi on OrderStatus {
  Color get color => switch (this) {
        OrderStatus.pending => AppColors.warning,
        OrderStatus.preparing => AppColors.secondary,
        OrderStatus.shipped => AppColors.primary,
        OrderStatus.delivered => AppColors.success,
        OrderStatus.cancelled => AppColors.danger,
      };

  IconData get icon => switch (this) {
        OrderStatus.pending => Icons.hourglass_top_rounded,
        OrderStatus.preparing => Icons.inventory_2_outlined,
        OrderStatus.shipped => Icons.local_shipping_outlined,
        OrderStatus.delivered => Icons.check_circle_outline,
        OrderStatus.cancelled => Icons.cancel_outlined,
      };
}

/// Renkli sipariş durumu rozeti.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
