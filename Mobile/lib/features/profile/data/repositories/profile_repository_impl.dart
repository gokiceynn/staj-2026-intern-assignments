import '../../../../core/config/app_config.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_mock_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/address_model.dart';

/// `USE_MOCK` bayrağına göre mock veya gerçek API'ye yönlendirir —
/// auth/catalog'daki desenle aynı.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileMockDataSource mock,
    required ProfileRemoteDataSource remote,
  })  : _mock = mock,
        _remote = remote;

  final ProfileMockDataSource _mock;
  final ProfileRemoteDataSource _remote;

  @override
  Future<List<Address>> getAddresses() =>
      AppConfig.useMock ? _mock.getAddresses() : _remote.getAddresses();

  @override
  Future<Address> saveAddress(Address address) => AppConfig.useMock
      ? _mock.saveAddress(AddressModel.fromEntity(address))
      : _remote.saveAddress(AddressModel.fromEntity(address));

  @override
  Future<void> deleteAddress(String id) =>
      AppConfig.useMock ? _mock.deleteAddress(id) : _remote.deleteAddress(id);
}
