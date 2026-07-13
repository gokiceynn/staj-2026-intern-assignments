import '../../../../core/error/app_exception.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../../core/storage/token_store.dart';
import '../../../profile/data/models/address_model.dart';
import '../models/order_model.dart';

/// Sipariş işlemleri. Ödeme simülasyonu için oluşturma isteğine
/// bilinçli olarak daha uzun gecikme eklenir.
class OrderMockDataSource {
  OrderMockDataSource(this._db, this._tokenStore);

  final MockDatabase _db;
  final TokenStore _tokenStore;

  Future<String> _requireUserId() async {
    final userId = await _tokenStore.readUserId();
    if (userId == null) throw const UnauthorizedException();
    return userId;
  }

  Future<OrderModel> createOrder({
    required AddressModel address,
    required String cardLast4,
  }) async {
    final userId = await _requireUserId();
    // Banka/ödeme sağlayıcısı gecikmesi simülasyonu.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    return _db.createOrder(
      userId: userId,
      address: address,
      cardLast4: cardLast4,
    );
  }

  Future<List<OrderModel>> getMyOrders() async {
    final userId = await _requireUserId();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _db.ordersFor(userId);
  }

  Future<OrderModel> getOrder(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _db.orderById(id);
  }
}
