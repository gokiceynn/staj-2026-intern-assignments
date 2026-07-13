import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_mock_data_source.dart';

/// NOT (contract-first): `/admin/*` uçları backend sözleşmesinde netleşince
/// `AdminRemoteDataSource` eklenip `AppConfig.useMock` ile seçilecek.
class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._mock);

  final AdminMockDataSource _mock;

  @override
  Future<AdminStats> getStats() => _mock.getStats();

  @override
  Future<List<Order>> getAllOrders() => _mock.getAllOrders();

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) =>
      _mock.updateOrderStatus(orderId, status);

  @override
  Future<Product> upsertProduct(Product product) =>
      _mock.upsertProduct(ProductModel.fromEntity(product));

  @override
  Future<void> deleteProduct(String productId) =>
      _mock.deleteProduct(productId);
}
