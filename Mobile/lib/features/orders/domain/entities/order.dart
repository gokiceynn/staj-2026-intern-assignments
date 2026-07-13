import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending('Onay Bekliyor'),
  preparing('Hazırlanıyor'),
  shipped('Kargoda'),
  delivered('Teslim Edildi'),
  cancelled('İptal Edildi');

  const OrderStatus(this.label);

  final String label;

  /// Sipariş hâlâ aktif akışta mı (iptal edilmemiş/teslim edilmemiş)?
  bool get isActive => this != cancelled && this != delivered;
}

/// Sipariş anındaki ürün görüntüsü (fiyat değişse bile sipariş sabit kalır).
class OrderItem extends Equatable {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  double get lineTotal => price * quantity;

  @override
  List<Object?> get props => [productId, name, imageUrl, price, quantity];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.recipientName,
    required this.addressText,
    required this.cardLast4,
    required this.subtotal,
    required this.couponDiscount,
    required this.shippingFee,
    required this.total,
    this.couponCode,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final List<OrderItem> items;
  final String recipientName;
  final String addressText;
  final String cardLast4;
  final double subtotal;
  final double couponDiscount;
  final double shippingFee;
  final double total;
  final String? couponCode;
  final OrderStatus status;
  final DateTime createdAt;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        recipientName,
        addressText,
        cardLast4,
        subtotal,
        couponDiscount,
        shippingFee,
        total,
        couponCode,
        status,
        createdAt,
      ];
}
