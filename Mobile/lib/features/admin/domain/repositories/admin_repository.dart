import '../../../catalog/domain/entities/product.dart';
import '../../../orders/domain/entities/order.dart';
import '../entities/admin_stats.dart';

abstract interface class AdminRepository {
  Future<AdminStats> getStats();

  /// Satıcının kendi ürünleri (genel katalog değil).
  Future<List<Product>> getMyProducts();

  Future<List<Order>> getAllOrders();

  Future<Order> updateOrderStatus(String orderId, OrderStatus status);

  /// id boşsa yeni ürün oluşturur, doluysa günceller.
  Future<Product> upsertProduct(Product product);

  Future<void> deleteProduct(String productId);
}
