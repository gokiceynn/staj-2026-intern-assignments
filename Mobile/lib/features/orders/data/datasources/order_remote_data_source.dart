import 'dart:math';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_store.dart';
import '../../../profile/data/models/address_model.dart';
import '../models/order_model.dart';

/// Gerçek API sipariş uçları (`OrdersController`).
/// Liste ucu (`ListMyOrdersHandler`) yalnızca özet döner (`itemCount`,
/// ürün yok); sipariş kartlarında ürün küçük resimleri gösterildiğinden
/// (bkz. `orders_screen.dart`) her sipariş için ayrıca detay çekilir.
class OrderRemoteDataSource {
  OrderRemoteDataSource(this._client, this._tokenStore);

  final DioClient _client;
  final TokenStore _tokenStore;

  Future<String> _requireUserId() async {
    final userId = await _tokenStore.readUserId();
    return userId ?? '';
  }

  Future<OrderModel> createOrder({
    required AddressModel address,
    required String cardHolderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  }) async {
    try {
      final idempotencyKey =
          '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.ordersCheckout,
        data: {
          'addressId': address.id,
          // Backend alan adı "expiry" değil "expire" (PaymentCardRequest.cs).
          'paymentCard': {
            'cardHolderName': cardHolderName,
            'cardNumber': cardNumber,
            'expireMonth': expiryMonth,
            'expireYear': expiryYear,
            'cvv': cvv,
          },
        },
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      return OrderModel.fromRemoteJson(
        response.data!,
        userId: await _requireUserId(),
        recipientName: address.fullName,
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final userId = await _requireUserId();
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.orders,
        queryParameters: {'page': 1, 'size': 20},
      );
      final ids = (response.data!['items'] as List)
          .cast<Map<String, dynamic>>()
          .map((e) => e['orderId'].toString())
          .toList();
      final details = await Future.wait(ids.map(_getOrderRaw));
      return details
          .map((json) => OrderModel.fromRemoteJson(json, userId: userId))
          .toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<Map<String, dynamic>> _getOrderRaw(String id) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiEndpoints.order(id),
    );
    return response.data!;
  }

  Future<OrderModel> getOrder(String id) async {
    try {
      final json = await _getOrderRaw(id);
      return OrderModel.fromRemoteJson(json, userId: await _requireUserId());
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
