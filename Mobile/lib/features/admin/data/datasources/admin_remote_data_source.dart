import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/admin_stats.dart';

/// Gerçek API mağaza yönetimi uçları.
///
/// Mobildeki tek "admin" özelliği kapsam olarak backend'in `AdminController`
/// (platform geneli, salt-okunur denetim) değil `SellerController`
/// (kendi ürün/sipariş yönetimi) rolüyle örtüşüyor — ürün CRUD'u ve sipariş
/// durum geçişleri yalnızca satıcı uçlarında var. Bu yüzden bu kaynak
/// `/seller/*` uçlarını kullanır.
class AdminRemoteDataSource {
  AdminRemoteDataSource(this._client);

  final DioClient _client;

  Future<AdminStats> getStats() async {
    try {
      final response = await _client.dio
          .get<Map<String, dynamic>>('/seller/dashboard');
      final d = response.data!;
      return AdminStats(
        totalRevenue: (d['grossSalesAmount'] as num).toDouble(),
        orderCount: (d['totalOrderCount'] as num).toInt(),
        productCount: (d['productCount'] as num).toInt(),
        customerCount: 0,
        outOfStockCount: (d['lowStockProductCount'] as num?)?.toInt() ?? 0,
        statusBreakdown: {
          OrderStatus.preparing: (d['preparingPackageCount'] as num?)?.toInt() ?? 0,
          OrderStatus.shipped: (d['shippedPackageCount'] as num?)?.toInt() ?? 0,
          OrderStatus.delivered: (d['deliveredPackageCount'] as num?)?.toInt() ?? 0,
          OrderStatus.cancelled: (d['cancelledPackageCount'] as num?)?.toInt() ?? 0,
          OrderStatus.pending: (d['paidPackageCount'] as num?)?.toInt() ?? 0,
        },
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Order _fromPackageDetail(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final address = json['shippingAddress'] as Map<String, dynamic>?;
    return OrderModel(
      id: json['packageId'].toString(),
      userId: json['orderId'].toString(),
      items: (json['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (item) => OrderItemModel(
              productId: item['productId'].toString(),
              name: (item['productTitle'] ?? '').toString(),
              imageUrl: item['photoId'] != null
                  ? '${_client.dio.options.baseUrl}/photos/${item['photoId']}'
                  : '',
              price: (item['price'] as num).toDouble(),
              quantity: (item['quantity'] as num).toInt(),
            ),
          )
          .toList(),
      recipientName: (customer?['fullName'] ?? '').toString(),
      addressText: address == null
          ? ''
          : '${address['addressLine']}, ${address['district']} / ${address['city']}',
      cardLast4: '••••',
      subtotal: (json['subtotal'] as num).toDouble(),
      couponDiscount: 0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0,
      total: (json['subtotal'] as num).toDouble() +
          ((json['shippingFee'] as num?)?.toDouble() ?? 0),
      status: OrderModel.statusFromRemote(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/seller/orders',
        queryParameters: {'page': 1, 'size': 50},
      );
      final ids = (response.data!['items'] as List)
          .cast<Map<String, dynamic>>()
          .map((e) => e['packageId'].toString())
          .toList();
      final details = await Future.wait(
        ids.map(
          (id) async => (await _client.dio
                  .get<Map<String, dynamic>>('/seller/orders/$id'))
              .data!,
        ),
      );
      return details.map(_fromPackageDetail).toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<Order> updateOrderStatus(String packageId, OrderStatus status) async {
    try {
      final path = switch (status) {
        OrderStatus.preparing => '/seller/orders/$packageId/prepare',
        OrderStatus.delivered => '/seller/orders/$packageId/deliver',
        OrderStatus.shipped => '/seller/orders/$packageId/ship',
        _ => throw const ValidationException(
            'Bu durum API modunda desteklenmiyor.',
          ),
      };
      Map<String, dynamic>? body;
      if (status == OrderStatus.shipped) {
        final carriers = await _client.dio
            .get<List<dynamic>>('/seller/shipping-carriers');
        final list = carriers.data!.cast<Map<String, dynamic>>();
        if (list.isEmpty) {
          throw const ValidationException('Tanımlı kargo firması yok.');
        }
        final carrierId = list.first['id'];
        body = {'carrierId': carrierId, 'trackingNumber': ''};
      }
      final response = await _client.dio
          .post<Map<String, dynamic>>(path, data: body);
      return _fromPackageDetail(response.data!);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DioClient.mapError(e);
    }
  }

  /// `GET /seller/products` — satıcının KENDİ ürünleri (genel katalog değil).
  Future<List<Product>> getMyProducts() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/seller/products',
        queryParameters: {'page': 1, 'size': 100},
      );
      final page = response.data!['page'] as Map<String, dynamic>;
      return (page['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (item) => ProductModel.fromSummaryJson(
              item['product'] as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<Product> upsertProduct(Product product) async {
    try {
      // Görsel yükleme ekranı henüz yok — düzenlerken mevcut fotoğrafı
      // silmemek için `images` (URL) içindeki photoId'ler geri çıkarılır.
      // Backend en az 1 fotoğraf ID'si istiyor; yeni üründe hâlâ yoksa
      // (görsel yükleme akışı eklenene kadar) düzenleme adımı gerekir.
      final photoIds = product.images
          .map((url) => url.split('/').last)
          .where((id) => id.isNotEmpty)
          .toList();
      final data = {
        'title': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock,
        'categoryId': product.categoryId,
        'photoIds': photoIds,
        'features': const <String>[],
        'isActive': true,
      };
      final response = product.id.isEmpty
          ? await _client.dio.post<Map<String, dynamic>>(
              '/seller/products',
              data: data,
            )
          : await _client.dio.put<Map<String, dynamic>>(
              '/seller/products/${product.id}',
              data: data,
            );
      return ProductModel.fromSummaryJson(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _client.dio.delete<void>('/seller/products/$productId');
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
