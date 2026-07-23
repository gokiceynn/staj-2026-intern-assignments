import '../../../../core/config/app_config.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_mock_data_source.dart';
import '../datasources/admin_remote_data_source.dart';

/// `USE_MOCK` bayrağına göre mock veya gerçek API'ye yönlendirir.
/// Gerçek modda `/seller/*` uçları kullanılır (bkz. [AdminRemoteDataSource]).
class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl({
    required AdminMockDataSource mock,
    required AdminRemoteDataSource remote,
  })  : _mock = mock,
        _remote = remote;

  final AdminMockDataSource _mock;
  final AdminRemoteDataSource _remote;

  @override
  Future<AdminStats> getStats() =>
      AppConfig.useMock ? _mock.getStats() : _remote.getStats();

  @override
  Future<List<Product>> getMyProducts() =>
      AppConfig.useMock ? _mock.getMyProducts() : _remote.getMyProducts();

  @override
  Future<List<Order>> getAllOrders() =>
      AppConfig.useMock ? _mock.getAllOrders() : _remote.getAllOrders();

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) =>
      AppConfig.useMock
          ? _mock.updateOrderStatus(orderId, status)
          : _remote.updateOrderStatus(orderId, status);

  @override
  Future<Product> upsertProduct(Product product) => AppConfig.useMock
      ? _mock.upsertProduct(ProductModel.fromEntity(product))
      : _remote.upsertProduct(product);

  @override
  Future<void> deleteProduct(String productId) => AppConfig.useMock
      ? _mock.deleteProduct(productId)
      : _remote.deleteProduct(productId);
}
