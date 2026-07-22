import 'package:json_annotation/json_annotation.dart';

import '../../../../core/config/app_config.dart';
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

  /// Backend `OrderDetailDto` (`GetMyOrder`/`Checkout`) → yerel [Order]
  /// şeması. Alan adları farklı (`orderId`/`totalAmount`/`shippingAmount`)
  /// ve backend kart/alıcı adı tutmadığından bu alanlar en iyi çaba ile
  /// (`recipientName` çağıran taraftan) doldurulur.
  factory OrderModel.fromRemoteJson(
    Map<String, dynamic> json, {
    required String userId,
    String? recipientName,
  }) {
    final address = json['shippingAddress'] as Map<String, dynamic>?;
    final addressText = address == null
        ? ''
        : '${address['addressLine']}, ${address['district']} / ${address['city']}';
    return OrderModel(
      id: json['orderId'].toString(),
      userId: userId,
      items: (json['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (item) => OrderItemModel(
              productId: item['productId'].toString(),
              name: (item['productTitle'] ?? '').toString(),
              imageUrl: item['photoId'] != null
                  ? '${AppConfig.apiBaseUrl}/photos/${item['photoId']}'
                  : '',
              price: (item['price'] as num).toDouble(),
              quantity: (item['quantity'] as num).toInt(),
            ),
          )
          .toList(),
      recipientName: recipientName ?? (address?['phoneNumber'] ?? '').toString(),
      addressText: addressText,
      cardLast4: '••••',
      subtotal: (json['subtotal'] as num).toDouble(),
      couponDiscount: 0,
      shippingFee: (json['shippingAmount'] as num).toDouble(),
      total: (json['totalAmount'] as num).toDouble(),
      status: statusFromRemote(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static OrderStatus statusFromRemote(String status) {
    final s = status.toLowerCase();
    if (s.contains('cancel')) return OrderStatus.cancelled;
    if (s.contains('deliver')) return OrderStatus.delivered;
    if (s.contains('ship')) return OrderStatus.shipped;
    if (s.contains('prepar') || s.contains('process')) {
      return OrderStatus.preparing;
    }
    return OrderStatus.pending;
  }
}
