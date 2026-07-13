/// Backend ekibiyle üzerinde anlaşılacak API sözleşmesinin endpoint haritası.
///
/// Sözleşme-öncelikli (contract-first) çalışıyoruz: backend OpenAPI dokümanını
/// yayınladığında buradaki yollar sözleşmeyle birebir eşitlenir. Remote data
/// source'lar yalnızca bu sabitleri kullanır.
abstract final class ApiEndpoints {
  // auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const me = '/users/me';

  // catalog
  static const products = '/products';
  static String product(String id) => '/products/$id';
  static const categories = '/categories';
  static String productReviews(String id) => '/products/$id/reviews';

  // cart
  static const cart = '/cart';
  static const cartItems = '/cart/items';
  static String cartItem(String productId) => '/cart/items/$productId';

  // orders
  static const orders = '/orders';
  static String order(String id) => '/orders/$id';

  // users
  static const addresses = '/users/me/addresses';
  static String address(String id) => '/users/me/addresses/$id';

  // admin
  static const adminProducts = '/admin/products';
  static String adminProduct(String id) => '/admin/products/$id';
  static const adminOrders = '/admin/orders';
  static String adminOrderStatus(String id) => '/admin/orders/$id/status';
  static const adminStats = '/admin/stats';
}
