import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/address_model.dart';

/// Gerçek API adres uçları (`CustomerController`).
/// `AddressDto`: `{ id, title, addressLine, city, district, zipCode, phoneNumber }`.
/// Backend adres kaydına alıcı adı (`fullName`) tutmaz — kart üzerindeki isim
/// yerine hesap sahibinin adı gösterilir (bkz. [displayName]).
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client, this.displayName);

  final DioClient _client;

  /// Giriş yapmış kullanıcının görünen adı; adres listelerinde `fullName`
  /// alanını doldurmak için kullanılır (backend'de karşılığı yok).
  final String Function() displayName;

  AddressModel _fromDto(Map<String, dynamic> json) => AddressModel(
        id: json['id'].toString(),
        title: json['title'] as String,
        fullName: displayName(),
        phone: (json['phoneNumber'] ?? '').toString(),
        city: json['city'] as String,
        district: json['district'] as String,
        addressLine: json['addressLine'] as String,
        zipCode: (json['zipCode'] ?? '').toString(),
      );

  Map<String, dynamic> _toWriteRequest(AddressModel address) => {
        'title': address.title,
        'addressLine': address.addressLine,
        'city': address.city,
        'district': address.district,
        'zipCode': address.zipCode,
        'phoneNumber': address.phone,
      };

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        ApiEndpoints.addresses,
      );
      return response.data!.cast<Map<String, dynamic>>().map(_fromDto).toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<AddressModel> saveAddress(AddressModel address) async {
    try {
      final response = address.id.isEmpty
          ? await _client.dio.post<Map<String, dynamic>>(
              ApiEndpoints.addresses,
              data: _toWriteRequest(address),
            )
          : await _client.dio.put<Map<String, dynamic>>(
              ApiEndpoints.address(address.id),
              data: _toWriteRequest(address),
            );
      return _fromDto(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _client.dio.delete<void>(ApiEndpoints.address(id));
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
