import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../data/datasources/admin_mock_data_source.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepositoryImpl(
    AdminMockDataSource(ref.watch(mockDatabaseProvider)),
  ),
);

final adminStatsProvider = FutureProvider<AdminStats>(
  (ref) => ref.watch(adminRepositoryProvider).getStats(),
);

final adminOrdersProvider = FutureProvider<List<Order>>(
  (ref) => ref.watch(adminRepositoryProvider).getAllOrders(),
);

/// Yönetim aksiyonları: mutasyon sonrası müşteri tarafındaki cache'ler de
/// tazelenir ki iki taraf tutarlı kalsın.
final adminActionsProvider = Provider<AdminActions>(AdminActions.new);

class AdminActions {
  AdminActions(this._ref);

  final Ref _ref;

  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    final updated = await _ref
        .read(adminRepositoryProvider)
        .updateOrderStatus(orderId, status);
    _ref
      ..invalidate(adminOrdersProvider)
      ..invalidate(adminStatsProvider)
      ..invalidate(myOrdersProvider)
      ..invalidate(orderDetailProvider);
    return updated;
  }

  Future<Product> upsertProduct(Product product) async {
    final saved =
        await _ref.read(adminRepositoryProvider).upsertProduct(product);
    _invalidateCatalog();
    return saved;
  }

  Future<void> deleteProduct(String productId) async {
    await _ref.read(adminRepositoryProvider).deleteProduct(productId);
    _invalidateCatalog();
    // Ürün sepette/favorilerde olabilir — onları da tazele.
    _ref
      ..invalidate(cartControllerProvider)
      ..invalidate(favoritesControllerProvider);
  }

  void _invalidateCatalog() {
    _ref
      ..invalidate(productListProvider)
      ..invalidate(productDetailProvider)
      ..invalidate(flashDealsProvider)
      ..invalidate(featuredProductsProvider)
      ..invalidate(topRatedProductsProvider)
      ..invalidate(adminStatsProvider);
  }
}
