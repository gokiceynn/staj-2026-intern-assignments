import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../domain/entities/cart.dart';

/// Gerçek API sepet uçları (`ShoppingController`).
/// `CartDto`: `{ id, items: [{productId, quantity, lineTotal, product}], subtotal, totalQuantity }`.
/// Not: Backend kupon alanı döndürmez — kupon mobilde yalnızca mock modda
/// gösterilen bir vitrin özelliğidir, gerçek API'de yok sayılır.
class CartRemoteDataSource {
  CartRemoteDataSource(this._client);

  final DioClient _client;

  Cart _parse(Map<String, dynamic> json) {
    final items = (json['items'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (item) => CartItem(
            product: ProductModel.fromSummaryJson(
              item['product'] as Map<String, dynamic>,
            ),
            quantity: (item['quantity'] as num).toInt(),
          ),
        )
        .toList();
    return Cart(items: items);
  }

  Future<Cart> getCart() async {
    try {
      final response =
          await _client.dio.get<Map<String, dynamic>>(ApiEndpoints.cart);
      return _parse(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<Cart> addToCart(String productId, int quantity) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.cartItems,
        data: {'productId': productId, 'quantity': quantity},
      );
      return _parse(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<Cart> updateQuantity(String productId, int quantity) async {
    try {
      final response = await _client.dio.put<Map<String, dynamic>>(
        ApiEndpoints.cartItem(productId),
        data: {'quantity': quantity},
      );
      return _parse(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<Cart> removeFromCart(String productId) async {
    try {
      final response = await _client.dio
          .delete<Map<String, dynamic>>(ApiEndpoints.cartItem(productId));
      return _parse(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<Cart> clearCart() async {
    try {
      final response =
          await _client.dio.delete<Map<String, dynamic>>(ApiEndpoints.cart);
      return _parse(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  /// Backend kupon uçları yayınlamıyor; kupon uygulaması API modunda
  /// desteklenmiyor. Ekran, `useMock == false` iken kupon alanını gizler
  /// (bkz. `cart_providers.dart`).
  Future<Cart> applyCoupon(String code) => getCart();

  Future<Cart> removeCoupon() => getCart();
}
