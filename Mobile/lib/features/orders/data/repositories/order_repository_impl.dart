import '../../../../core/config/app_config.dart';
import '../../../profile/data/models/address_model.dart';
import '../../../profile/domain/entities/address.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_mock_data_source.dart';
import '../datasources/order_remote_data_source.dart';

/// `USE_MOCK` bayrağına göre mock veya gerçek API'ye yönlendirir —
/// auth/catalog'daki desenle aynı.
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderMockDataSource mock,
    required OrderRemoteDataSource remote,
  })  : _mock = mock,
        _remote = remote;

  final OrderMockDataSource _mock;
  final OrderRemoteDataSource _remote;

  @override
  Future<Order> createOrder({
    required Address address,
    required String cardHolderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  }) =>
      AppConfig.useMock
          ? _mock.createOrder(
              address: AddressModel.fromEntity(address),
              cardNumber: cardNumber,
            )
          : _remote.createOrder(
              address: AddressModel.fromEntity(address),
              cardHolderName: cardHolderName,
              cardNumber: cardNumber,
              expiryMonth: expiryMonth,
              expiryYear: expiryYear,
              cvv: cvv,
            );

  @override
  Future<List<Order>> getMyOrders() =>
      AppConfig.useMock ? _mock.getMyOrders() : _remote.getMyOrders();

  @override
  Future<Order> getOrder(String id) =>
      AppConfig.useMock ? _mock.getOrder(id) : _remote.getOrder(id);
}
