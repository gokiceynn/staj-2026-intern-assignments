import 'package:equatable/equatable.dart';

enum UserRole { customer, admin, seller }

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

  /// "Admin Paneli" ekranı aslında `SellerController` uçlarına bağlı (ürün/
  /// sipariş yönetimi) — hem gerçek admin hem satıcı rolü buraya erişebilir.
  /// Bkz. `admin/data/datasources/admin_remote_data_source.dart`.
  bool get canManageStore => role == UserRole.admin || role == UserRole.seller;

  @override
  List<Object?> get props => [id, name, email, phone, role];
}
