import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_mock_data_source.dart';

/// Sepet repository'si.
///
/// NOT (contract-first): Sepet uçları (`/cart/items`) backend OpenAPI
/// sözleşmesinde netleşince buraya `CartRemoteDataSource` eklenecek ve
/// `AppConfig.useMock` bayrağıyla seçilecek — auth/catalog'daki desenle
/// birebir aynı. O güne kadar sepet cihaz-yerel çalışır (offline avantajı).
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._mock);

  final CartMockDataSource _mock;

  @override
  Future<Cart> getCart() => _mock.getCart();

  @override
  Future<Cart> addToCart(String productId, {int quantity = 1}) =>
      _mock.addToCart(productId, quantity);

  @override
  Future<Cart> updateQuantity(String productId, int quantity) =>
      _mock.updateQuantity(productId, quantity);

  @override
  Future<Cart> removeFromCart(String productId) =>
      _mock.removeFromCart(productId);

  @override
  Future<Cart> clearCart() => _mock.clearCart();

  @override
  Future<Cart> applyCoupon(String code) => _mock.applyCoupon(code);

  @override
  Future<Cart> removeCoupon() => _mock.removeCoupon();
}
