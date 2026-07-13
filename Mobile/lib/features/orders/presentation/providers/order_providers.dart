import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/domain/entities/address.dart';
import '../../data/datasources/order_mock_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepositoryImpl(
    OrderMockDataSource(
      ref.watch(mockDatabaseProvider),
      ref.watch(tokenStoreProvider),
    ),
  ),
);

/// Kullanıcının sipariş geçmişi; oturum değişince yeniden yüklenir.
final myOrdersProvider = FutureProvider<List<Order>>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(orderRepositoryProvider).getMyOrders();
});

final orderDetailProvider = FutureProvider.family<Order, String>(
  (ref, id) => ref.watch(orderRepositoryProvider).getOrder(id),
);

final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, void>(CheckoutController.new);

/// Sipariş oluşturma iş mantığı: ödeme simülasyonu sonrası ilgili tüm
/// cache'leri tazeler (sepet boşaldı, stoklar düştü).
class CheckoutController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Order> placeOrder({
    required Address address,
    required String cardLast4,
  }) async {
    state = const AsyncLoading();
    try {
      final order = await ref.read(orderRepositoryProvider).createOrder(
            address: address,
            cardLast4: cardLast4,
          );
      ref
        ..invalidate(cartControllerProvider)
        ..invalidate(myOrdersProvider)
        ..invalidate(productListProvider)
        ..invalidate(productDetailProvider)
        ..invalidate(flashDealsProvider)
        ..invalidate(featuredProductsProvider)
        ..invalidate(topRatedProductsProvider);
      state = const AsyncData(null);
      return order;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }
}
