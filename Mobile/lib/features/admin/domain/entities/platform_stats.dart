import 'package:equatable/equatable.dart';

/// Backend'in `AdminController` (platform geneli denetim) uçlarına karşılık
/// gelen salt-okunur veriler — mağaza yönetiminden (`AdminStats`/Seller)
/// ayrı, gerçek Admin rolüne özel.
class PlatformStats extends Equatable {
  const PlatformStats({
    required this.userCount,
    required this.customerCount,
    required this.sellerCount,
    required this.activeProductCount,
    required this.orderCount,
    required this.grossSalesAmount,
    required this.currency,
  });

  final int userCount;
  final int customerCount;
  final int sellerCount;
  final int activeProductCount;
  final int orderCount;
  final double grossSalesAmount;
  final String currency;

  @override
  List<Object?> get props => [
        userCount,
        customerCount,
        sellerCount,
        activeProductCount,
        orderCount,
        grossSalesAmount,
        currency,
      ];
}

class PlatformUser extends Equatable {
  const PlatformUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.isEmailVerified,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final bool isEmailVerified;

  @override
  List<Object?> get props =>
      [id, email, fullName, role, isActive, isEmailVerified];
}

class PlatformSeller extends Equatable {
  const PlatformSeller({
    required this.id,
    required this.storeName,
    required this.email,
    required this.rating,
    required this.isActive,
    required this.productCount,
  });

  final String id;
  final String storeName;
  final String email;
  final double rating;
  final bool isActive;
  final int productCount;

  @override
  List<Object?> get props =>
      [id, storeName, email, rating, isActive, productCount];
}
