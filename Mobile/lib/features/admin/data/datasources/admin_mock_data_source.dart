import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/admin_stats.dart';

class AdminMockDataSource {
  AdminMockDataSource(this._db);

  final MockDatabase _db;

  Future<T> _withLatency<T>(T Function() action) async {
    await Future<void>.delayed(AppConfig.mockLatency ~/ 2);
    return action();
  }

  Future<AdminStats> getStats() => _withLatency(() {
        final stats = _db.stats();
        return AdminStats(
          totalRevenue: stats.totalRevenue,
          orderCount: stats.orderCount,
          productCount: stats.productCount,
          customerCount: stats.customerCount,
          outOfStockCount: stats.outOfStockCount,
          statusBreakdown: stats.statusBreakdown,
        );
      });

  Future<List<OrderModel>> getAllOrders() => _withLatency(_db.allOrders);

  Future<List<ProductModel>> getMyProducts() =>
      _withLatency(() => _db.allProducts);

  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus status) =>
      _withLatency(() => _db.updateOrderStatus(orderId, status));

  Future<ProductModel> upsertProduct(ProductModel product) =>
      _withLatency(() => _db.upsertProduct(product));

  Future<void> deleteProduct(String productId) =>
      _withLatency(() => _db.deleteProduct(productId));
}
