import '../entities/address.dart';

abstract interface class ProfileRepository {
  Future<List<Address>> getAddresses();

  /// id boşsa yeni kayıt oluşturur, doluysa günceller.
  Future<Address> saveAddress(Address address);

  Future<void> deleteAddress(String id);
}
