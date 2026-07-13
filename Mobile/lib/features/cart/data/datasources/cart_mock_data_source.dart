import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/cart.dart';

/// Sepet işlemlerini [MockDatabase] üzerinde yürütür.
class CartMockDataSource {
  CartMockDataSource(this._db);

  final MockDatabase _db;

  Future<T> _withLatency<T>(T Function() action) async {
    await Future<void>.delayed(AppConfig.mockLatency ~/ 2);
    return action();
  }

  Future<Cart> getCart() => _withLatency(_db.getCart);

  Future<Cart> addToCart(String productId, int quantity) =>
      _withLatency(() => _db.addToCart(productId, quantity));

  Future<Cart> updateQuantity(String productId, int quantity) =>
      _withLatency(() => _db.updateCartQuantity(productId, quantity));

  Future<Cart> removeFromCart(String productId) =>
      _withLatency(() => _db.removeFromCart(productId));

  Future<Cart> clearCart() => _withLatency(_db.clearCart);

  Future<Cart> applyCoupon(String code) =>
      _withLatency(() => _db.applyCoupon(code));

  Future<Cart> removeCoupon() => _withLatency(_db.removeCoupon);
}
