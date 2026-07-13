import 'package:equatable/equatable.dart';

import '../../../../core/config/app_config.dart';
import '../../../catalog/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  @override
  List<Object?> get props => [product, quantity];
}

/// İndirim kuponu. Yüzdesel (percentOff) veya sabit tutar (amountOff).
class Coupon extends Equatable {
  const Coupon({
    required this.code,
    required this.description,
    this.percentOff = 0,
    this.amountOff = 0,
    this.minSubtotal = 0,
  });

  final String code;
  final String description;
  final double percentOff;
  final double amountOff;
  final double minSubtotal;

  double discountFor(double subtotal) {
    if (subtotal < minSubtotal) return 0;
    final discount = percentOff > 0 ? subtotal * percentOff / 100 : amountOff;
    return discount.clamp(0, subtotal);
  }

  @override
  List<Object?> get props =>
      [code, description, percentOff, amountOff, minSubtotal];
}

/// Sepet + tüm tutar hesapları. Hesaplar tek yerde (domain) durur;
/// UI ve testler aynı kaynağı kullanır.
class Cart extends Equatable {
  const Cart({this.items = const [], this.coupon});

  final List<CartItem> items;
  final Coupon? coupon;

  bool get isEmpty => items.isEmpty;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  double get couponDiscount => coupon?.discountFor(subtotal) ?? 0;

  /// Kupon sonrası ara toplam kargo eşiğini geçiyorsa kargo bedava.
  double get shippingFee {
    if (items.isEmpty) return 0;
    final afterDiscount = subtotal - couponDiscount;
    return afterDiscount >= AppConfig.freeShippingThreshold
        ? 0
        : AppConfig.shippingFee;
  }

  double get grandTotal => subtotal - couponDiscount + shippingFee;

  /// Kargo bedava eşiğine kalan tutar (0 ise eşik aşıldı).
  double get remainingForFreeShipping {
    final afterDiscount = subtotal - couponDiscount;
    final remaining = AppConfig.freeShippingThreshold - afterDiscount;
    return remaining > 0 ? remaining : 0;
  }

  @override
  List<Object?> get props => [items, coupon];
}
