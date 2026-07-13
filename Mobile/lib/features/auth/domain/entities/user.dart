import 'package:equatable/equatable.dart';

enum UserRole { customer, admin }

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = UserRole.customer,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, name, email, phone, role];
}
