import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Backend `AccountSummary` şeması: `{id, email, firstName, lastName,
  /// phoneNumber, role, createdAt}` — mock modun düz `{name, phone}`
  /// şeklinden farklı olduğu için ayrı bir dönüştürücü.
  factory UserModel.fromAccountSummary(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();
    final role = (json['role'] ?? '').toString().toLowerCase();
    return UserModel(
      id: json['id'].toString(),
      name: '$firstName $lastName'.trim(),
      email: json['email'] as String,
      phone: json['phoneNumber'] as String?,
      role: switch (role) {
        'admin' => UserRole.admin,
        'seller' => UserRole.seller,
        _ => UserRole.customer,
      },
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
