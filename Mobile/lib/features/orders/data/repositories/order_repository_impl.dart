import '../../../profile/data/models/address_model.dart';
import '../../../profile/domain/entities/address.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_mock_data_source.dart';

/// NOT (contract-first): `/orders` uçları backend sözleşmesinde netleşince
/// `OrderRemoteDataSource` eklenip `AppConfig.useMock` ile seçilecek.
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._mock);

  final OrderMockDataSource _mock;

  @override
  Future<Order> createOrder({
    required Address address,
    required String cardLast4,
  }) =>
      _mock.createOrder(
        address: AddressModel.fromEntity(address),
        cardLast4: cardLast4,
      );

  @override
  Future<List<Order>> getMyOrders() => _mock.getMyOrders();

  @override
  Future<Order> getOrder(String id) => _mock.getOrder(id);
}
