import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/address.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.title,
    required super.fullName,
    required super.phone,
    required super.city,
    required super.district,
    required super.addressLine,
    super.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  factory AddressModel.fromEntity(Address address) => AddressModel(
        id: address.id,
        title: address.title,
        fullName: address.fullName,
        phone: address.phone,
        city: address.city,
        district: address.district,
        addressLine: address.addressLine,
        zipCode: address.zipCode,
      );

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
