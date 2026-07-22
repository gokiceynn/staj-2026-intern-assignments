import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.id,
    required this.title,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.district,
    required this.addressLine,
    this.zipCode = '',
  });

  final String id;

  /// "Ev", "İş" gibi kısa etiket.
  final String title;

  final String fullName;
  final String phone;
  final String city;
  final String district;
  final String addressLine;

  /// Posta kodu — gerçek API adres kaydı için zorunlu; mock modda kullanılmaz.
  final String zipCode;

  String get summary => '$addressLine, $district / $city';

  @override
  List<Object?> get props =>
      [id, title, fullName, phone, city, district, addressLine, zipCode];
}
