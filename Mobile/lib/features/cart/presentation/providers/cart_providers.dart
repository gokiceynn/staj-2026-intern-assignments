import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/datasources/cart_mock_data_source.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositoryImpl(
    CartMockDataSource(ref.watch(mockDatabaseProvider)),
  ),
);

final cartControllerProvider =
    AsyncNotifierProvider<CartController, Cart>(CartController.new);

/// Sepet iş mantığı. Stok/kupon doğrulama hataları [ValidationException]
/// olarak yukarı fırlar; ekranlar SnackBar ile gösterir.
class CartController extends AsyncNotifier<Cart> {
  @override
  Future<Cart> build() => ref.watch(cartRepositoryProvider).getCart();

  Future<void> add(String productId, {int quantity = 1}) async {
    final cart = await ref
        .read(cartRepositoryProvider)
        .addToCart(productId, quantity: quantity);
    state = AsyncData(cart);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final cart = await ref
        .read(cartRepositoryProvider)
        .updateQuantity(productId, quantity);
    state = AsyncData(cart);
  }

  Future<void> remove(String productId) async {
    final cart =
        await ref.read(cartRepositoryProvider).removeFromCart(productId);
    state = AsyncData(cart);
  }

  Future<void> clear() async {
    final cart = await ref.read(cartRepositoryProvider).clearCart();
    state = AsyncData(cart);
  }

  Future<void> applyCoupon(String code) async {
    final cart = await ref.read(cartRepositoryProvider).applyCoupon(code);
    state = AsyncData(cart);
  }

  Future<void> removeCoupon() async {
    final cart = await ref.read(cartRepositoryProvider).removeCoupon();
    state = AsyncData(cart);
  }
}

/// Alt menüdeki sepet rozeti.
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartControllerProvider).value?.totalQuantity ?? 0,
);
