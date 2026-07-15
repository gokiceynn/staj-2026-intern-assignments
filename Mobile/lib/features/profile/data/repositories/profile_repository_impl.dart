import '../../domain/entities/address.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_mock_data_source.dart';
import '../models/address_model.dart';

/// NOT (contract-first): `/customer/me/addresses` uçları v1.3 sözleşmesinde
/// tanımlıdır; backend hazır olunca `ProfileRemoteDataSource` eklenip `AppConfig.useMock` ile
/// seçilecek — auth/catalog'daki desenle aynı.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._mock);

  final ProfileMockDataSource _mock;

  @override
  Future<List<Address>> getAddresses() => _mock.getAddresses();

  @override
  Future<Address> saveAddress(Address address) =>
      _mock.saveAddress(AddressModel.fromEntity(address));

  @override
  Future<void> deleteAddress(String id) => _mock.deleteAddress(id);
}
