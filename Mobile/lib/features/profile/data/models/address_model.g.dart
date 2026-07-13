// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  id: json['id'] as String,
  title: json['title'] as String,
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  city: json['city'] as String,
  district: json['district'] as String,
  addressLine: json['addressLine'] as String,
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'city': instance.city,
      'district': instance.district,
      'addressLine': instance.addressLine,
    };
