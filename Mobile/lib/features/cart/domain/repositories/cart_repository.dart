import '../entities/cart.dart';

abstract interface class CartRepository {
  Future<Cart> getCart();

  Future<Cart> addToCart(String productId, {int quantity = 1});

  Future<Cart> updateQuantity(String productId, int quantity);

  Future<Cart> removeFromCart(String productId);

  Future<Cart> clearCart();

  Future<Cart> applyCoupon(String code);

  Future<Cart> removeCoupon();
}
