import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../../core/storage/token_store.dart';
import '../models/address_model.dart';

/// Adres işlemleri — mock veri. Backend hazır olunca `ProfileRemoteDataSource` ile
/// `/customer/me/addresses` uçlarına geçilir.
class ProfileMockDataSource {
  ProfileMockDataSource(this._db, this._tokenStore);

  final MockDatabase _db;
  final TokenStore _tokenStore;

  Future<String> _requireUserId() async {
    final userId = await _tokenStore.readUserId();
    if (userId == null) throw const UnauthorizedException();
    return userId;
  }

  Future<List<AddressModel>> getAddresses() async {
    await Future<void>.delayed(AppConfig.mockLatency ~/ 2);
    return _db.addressesFor(await _requireUserId());
  }

  Future<AddressModel> saveAddress(AddressModel address) async {
    await Future<void>.delayed(AppConfig.mockLatency ~/ 2);
    return _db.saveAddress(await _requireUserId(), address);
  }

  Future<void> deleteAddress(String id) async {
    await Future<void>.delayed(AppConfig.mockLatency ~/ 2);
    _db.deleteAddress(await _requireUserId(), id);
  }
}
