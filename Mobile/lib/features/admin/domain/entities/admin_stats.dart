import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order.dart';

/// Admin dashboard istatistikleri.
class AdminStats extends Equatable {
  const AdminStats({
    required this.totalRevenue,
    required this.orderCount,
    required this.productCount,
    required this.customerCount,
    required this.outOfStockCount,
    required this.statusBreakdown,
  });

  /// İptal edilen siparişler hariç toplam ciro.
  final double totalRevenue;
  final int orderCount;
  final int productCount;
  final int customerCount;
  final int outOfStockCount;
  final Map<OrderStatus, int> statusBreakdown;

  int get pendingCount => statusBreakdown[OrderStatus.pending] ?? 0;

  @override
  List<Object?> get props => [
        totalRevenue,
        orderCount,
        productCount,
        customerCount,
        outOfStockCount,
        statusBreakdown,
      ];
}
