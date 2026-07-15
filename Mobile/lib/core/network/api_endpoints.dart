/// API v1.3 sözleşmesi endpoint haritası.
///
/// Kaynak: `Docs/ecommerce_api_contract_v1.3.md` (§2.0 netleştirilmiş kararlar).
/// Remote data source'lar yalnızca bu sabitleri kullanır.
abstract final class ApiEndpoints {
  // auth
  static const login = '/auth/login';
  static const customerRegister = '/auth/customer/register';
  static const sellerRegister = '/auth/seller/register';
  /// Müşteri kaydı için kısayol — `customerRegister` ile aynı.
  static const register = customerRegister;
  static const refreshToken = '/auth/refresh-token';
  static const logout = '/auth/logout';
  static const emailVerify = '/auth/email/verify';
  static const emailResend = '/auth/email/resend';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  // account (ortak profil — Customer / Seller / Admin)
  static const accountMe = '/account/me';
  /// Geriye dönük alias; yeni kod `accountMe` kullanmalı.
  static const me = accountMe;

  // customer
  static const deleteCustomerAccount = '/customer/me';
  static const addresses = '/customer/me/addresses';
  static String address(String id) => '/customer/me/addresses/$id';

  // metadata
  static const metadataStatuses = '/metadata/statuses';

  // catalog
  static const products = '/products';
  static String product(String id) => '/products/$id';
  static const categories = '/categories';
  static String productReviews(String id) => '/products/$id/reviews';
  static String productReview(String productId, String reviewId) =>
      '/products/$productId/reviews/$reviewId';

  // favorites
  static const favorites = '/favorites';
  static String favorite(String productId) => '/favorites/$productId';

  // cart
  static const cart = '/cart';
  static const cartItems = '/cart/items';
  static String cartItem(String productId) => '/cart/items/$productId';

  // payments
  static const paymentsSimulate = '/payments/simulate';

  // orders
  static const ordersCheckout = '/orders/checkout';
  static const orders = '/orders';
  static String order(String id) => '/orders/$id';
  static String orderCancel(String id) => '/orders/$id/cancel';

  // photos
  static const photos = '/photos';
  static String photo(String id) => '/photos/$id';

  // seller (ileride)
  static const sellerProfile = '/seller/profile';
  static const sellerDashboard = '/seller/dashboard';

  // admin (ileride)
  static const adminDashboard = '/admin/dashboard';
  static const adminUsers = '/admin/users';
  static const adminSellers = '/admin/sellers';
  static const adminOrders = '/admin/orders';
}
