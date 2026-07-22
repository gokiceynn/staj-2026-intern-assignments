import '../../../../core/config/app_config.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_mock_data_source.dart';
import '../datasources/cart_remote_data_source.dart';

/// `USE_MOCK` bayrağına göre mock veya gerçek API'ye yönlendirir —
/// auth/catalog'daki desenle aynı.
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required CartMockDataSource mock, required CartRemoteDataSource remote})
      : _mock = mock,
        _remote = remote;

  final CartMockDataSource _mock;
  final CartRemoteDataSource _remote;

  @override
  Future<Cart> getCart() =>
      AppConfig.useMock ? _mock.getCart() : _remote.getCart();

  @override
  Future<Cart> addToCart(String productId, {int quantity = 1}) => AppConfig.useMock
      ? _mock.addToCart(productId, quantity)
      : _remote.addToCart(productId, quantity);

  @override
  Future<Cart> updateQuantity(String productId, int quantity) => AppConfig.useMock
      ? _mock.updateQuantity(productId, quantity)
      : _remote.updateQuantity(productId, quantity);

  @override
  Future<Cart> removeFromCart(String productId) => AppConfig.useMock
      ? _mock.removeFromCart(productId)
      : _remote.removeFromCart(productId);

  @override
  Future<Cart> clearCart() =>
      AppConfig.useMock ? _mock.clearCart() : _remote.clearCart();

  @override
  Future<Cart> applyCoupon(String code) => AppConfig.useMock
      ? _mock.applyCoupon(code)
      : _remote.applyCoupon(code);

  @override
  Future<Cart> removeCoupon() =>
      AppConfig.useMock ? _mock.removeCoupon() : _remote.removeCoupon();
}
