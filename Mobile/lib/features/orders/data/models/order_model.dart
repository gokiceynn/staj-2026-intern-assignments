import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/order.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    required super.name,
    required super.imageUrl,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  factory OrderItemModel.fromEntity(OrderItem item) => OrderItemModel(
        productId: item.productId,
        name: item.name,
        imageUrl: item.imageUrl,
        price: item.price,
        quantity: item.quantity,
      );

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.userId,
    required this.items,
    required super.recipientName,
    required super.addressText,
    required super.cardLast4,
    required super.subtotal,
    required super.couponDiscount,
    required super.shippingFee,
    required super.total,
    super.couponCode,
    required super.status,
    required super.createdAt,
  }) : super(items: items);

  /// json_serializable'ın öğe tipini çözebilmesi için model tipiyle
  /// yeniden bildirilir (entity alanını gölgeler, aynı listeyi taşır).
  @override
  // ignore: overridden_fields
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromEntity(Order order) => OrderModel(
        id: order.id,
        userId: order.userId,
        items: [
          for (final item in order.items) OrderItemModel.fromEntity(item),
        ],
        recipientName: order.recipientName,
        addressText: order.addressText,
        cardLast4: order.cardLast4,
        subtotal: order.subtotal,
        couponDiscount: order.couponDiscount,
        shippingFee: order.shippingFee,
        total: order.total,
        couponCode: order.couponCode,
        status: order.status,
        createdAt: order.createdAt,
      );

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
