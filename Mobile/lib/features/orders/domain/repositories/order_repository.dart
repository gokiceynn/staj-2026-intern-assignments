import '../../../profile/domain/entities/address.dart';
import '../entities/order.dart';

abstract interface class OrderRepository {
  /// Sepetteki ürünlerle sipariş oluşturur (ödeme simülasyonu).
  /// Başarılı olursa sepet temizlenir ve stoklar düşer.
  Future<Order> createOrder({
    required Address address,
    required String cardLast4,
  });

  Future<List<Order>> getMyOrders();

  Future<Order> getOrder(String id);
}
