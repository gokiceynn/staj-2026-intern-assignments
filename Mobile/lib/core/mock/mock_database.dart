import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../../features/auth/data/models/user_model.dart';
import '../../features/cart/domain/entities/cart.dart';
import '../../features/catalog/data/models/category_model.dart';
import '../../features/catalog/data/models/product_model.dart';
import '../../features/catalog/data/models/review_model.dart';
import '../../features/catalog/domain/entities/product_query.dart';
import '../../features/orders/data/models/order_model.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/profile/data/models/address_model.dart';
import '../error/app_exception.dart';
import '../storage/local_store.dart';

/// Sahte sunucu (in-memory backend simülasyonu).
///
/// Backend ekibi API'yi yayınlayana kadar uygulamanın uçtan uca çalışmasını
/// sağlar: seed verisini assets'ten yükler, tüm değişiklikleri (sepet,
/// siparişler, admin ürün düzenlemeleri...) SharedPreferences'a yazar.
/// `USE_MOCK=false` olduğunda repository'ler bu sınıf yerine Dio tabanlı
/// remote data source'ları kullanır — üst katmanlar farkı bilmez.
class MockDatabase {
  MockDatabase(this._store);

  final LocalStore _store;
  final Random _random = Random();

  static const _kProducts = 'mock.products';
  static const _kExtraReviews = 'mock.reviews.extra';
  static const _kExtraUsers = 'mock.users.extra';
  static const _kOrders = 'mock.orders';
  static const _kOrdersSeeded = 'mock.orders.seeded';
  static const _kAddresses = 'mock.addresses';
  static const _kCart = 'mock.cart';
  static const _kFavorites = 'mock.favorites';

  late List<ProductModel> _products;
  late List<CategoryModel> _categories;
  late List<ReviewModel> _reviews;

  /// Şifre alanı içerdiği için düz map olarak tutulur — yalnızca mock modda
  /// vardır; gerçek backend şifreleri bcrypt/argon2 ile saklar.
  late List<Map<String, dynamic>> _users;

  Map<String, int> _cartQuantities = {};
  String? _cartCouponCode;
  Set<String> _favoriteIds = {};
  List<OrderModel> _orders = [];
  Map<String, List<AddressModel>> _addressesByUser = {};

  static const List<Map<String, dynamic>> _seedUsers = [
    {
      'id': 'u-admin',
      'name': 'VBShop Yönetici',
      'email': 'admin@vbshop.com',
      'password': 'admin123',
      'role': 'admin',
      'phone': '+90 555 000 00 01',
    },
    {
      'id': 'u-demo',
      'name': 'Demo Kullanıcı',
      'email': 'demo@vbshop.com',
      'password': 'demo123',
      'role': 'customer',
      'phone': '+90 555 000 00 02',
    },
    {
      'id': 'u-ayse',
      'name': 'Ayşe Yılmaz',
      'email': 'ayse@ornek.com',
      'password': 'test123',
      'role': 'customer',
      'phone': '+90 555 000 00 03',
    },
    {
      'id': 'u-mehmet',
      'name': 'Mehmet Demir',
      'email': 'mehmet@ornek.com',
      'password': 'test123',
      'role': 'customer',
      'phone': '+90 555 000 00 04',
    },
  ];

  /// Tanımlı kuponlar. Gerçek API'de `/cart/coupon` endpoint'i doğrular.
  static const List<Coupon> coupons = [
    Coupon(
      code: 'VB10',
      description: 'Tüm sepette %10 indirim',
      percentOff: 10,
    ),
    Coupon(
      code: 'HOSGELDIN50',
      description: '300 TL üzeri sepetlerde 50 TL indirim',
      amountOff: 50,
      minSubtotal: 300,
    ),
  ];

  // ---------------------------------------------------------------- init

  Future<void> init() async {
    _categories = (await _loadAssetList('assets/data/categories.json'))
        .map(CategoryModel.fromJson)
        .toList();

    final storedProducts = _store.getJson(_kProducts);
    final productMaps = storedProducts is List
        ? storedProducts.cast<Map<String, dynamic>>()
        : await _loadAssetList('assets/data/products.json');
    _products = productMaps.map(ProductModel.fromJson).toList();

    _reviews = (await _loadAssetList('assets/data/reviews.json'))
        .map(ReviewModel.fromJson)
        .toList();
    final extraReviews = _store.getJson(_kExtraReviews);
    if (extraReviews is List) {
      _reviews.addAll(
        extraReviews.cast<Map<String, dynamic>>().map(ReviewModel.fromJson),
      );
    }

    _users = [..._seedUsers];
    final extraUsers = _store.getJson(_kExtraUsers);
    if (extraUsers is List) {
      _users.addAll(extraUsers.cast<Map<String, dynamic>>());
    }

    final cart = _store.getJson(_kCart);
    if (cart is Map) {
      _cartQuantities = (cart['items'] as Map? ?? {}).map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
      _cartCouponCode = cart['coupon'] as String?;
    }

    final favorites = _store.getJson(_kFavorites);
    if (favorites is List) {
      _favoriteIds = favorites.map((e) => e.toString()).toSet();
    }

    final orders = _store.getJson(_kOrders);
    if (orders is List) {
      _orders = orders
          .cast<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
    }

    final addresses = _store.getJson(_kAddresses);
    if (addresses is Map) {
      _addressesByUser = addresses.map(
        (userId, list) => MapEntry(
          userId.toString(),
          (list as List)
              .cast<Map<String, dynamic>>()
              .map(AddressModel.fromJson)
              .toList(),
        ),
      );
    }

    // İlk açılışta demo kullanıcı ve admin paneli boş görünmesin diye
    // örnek sipariş/adres verisi üret.
    if (_store.getString(_kOrdersSeeded) == null) {
      _seedOrdersAndAddresses();
      await _store.setString(_kOrdersSeeded, '1');
    }
  }

  Future<List<Map<String, dynamic>>> _loadAssetList(String path) async {
    final raw = await rootBundle.loadString(path);
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  void _seedOrdersAndAddresses() {
    if (_addressesByUser['u-demo'] == null) {
      _addressesByUser['u-demo'] = [
        const AddressModel(
          id: 'a-demo-1',
          title: 'Ev',
          fullName: 'Demo Kullanıcı',
          phone: '+90 555 000 00 02',
          city: 'İstanbul',
          district: 'Kadıköy',
          addressLine: 'Caferağa Mah. Moda Cad. No: 12 D: 5',
        ),
      ];
    }

    if (_orders.isEmpty) {
      final now = DateTime.now();
      OrderModel build({
        required String id,
        required String userId,
        required String recipient,
        required List<(String, int)> productQuantities,
        required OrderStatus status,
        required int daysAgo,
      }) {
        final items = productQuantities.map((pair) {
          final product = _products.firstWhere((p) => p.id == pair.$1);
          return OrderItemModel(
            productId: product.id,
            name: product.name,
            imageUrl: product.primaryImage,
            price: product.price,
            quantity: pair.$2,
          );
        }).toList();
        final subtotal =
            items.fold<double>(0, (sum, item) => sum + item.lineTotal);
        final shipping = subtotal >= 500 ? 0.0 : 39.99;
        return OrderModel(
          id: id,
          userId: userId,
          items: items,
          recipientName: recipient,
          addressText: 'Caferağa Mah. Moda Cad. No: 12, Kadıköy / İstanbul',
          cardLast4: '4242',
          subtotal: subtotal,
          couponDiscount: 0,
          shippingFee: shipping,
          total: subtotal + shipping,
          status: status,
          createdAt: now.subtract(Duration(days: daysAgo)),
        );
      }

      _orders = [
        build(
          id: 'VB100248',
          userId: 'u-demo',
          recipient: 'Demo Kullanıcı',
          productQuantities: [('p04', 1)],
          status: OrderStatus.shipped,
          daysAgo: 2,
        ),
        build(
          id: 'VB100231',
          userId: 'u-demo',
          recipient: 'Demo Kullanıcı',
          productQuantities: [('p25', 2), ('p19', 1)],
          status: OrderStatus.delivered,
          daysAgo: 12,
        ),
        build(
          id: 'VB100215',
          userId: 'u-ayse',
          recipient: 'Ayşe Yılmaz',
          productQuantities: [('p16', 1), ('p18', 1)],
          status: OrderStatus.pending,
          daysAgo: 1,
        ),
        build(
          id: 'VB100202',
          userId: 'u-mehmet',
          recipient: 'Mehmet Demir',
          productQuantities: [('p10', 1)],
          status: OrderStatus.preparing,
          daysAgo: 1,
        ),
        build(
          id: 'VB100195',
          userId: 'u-ayse',
          recipient: 'Ayşe Yılmaz',
          productQuantities: [('p29', 2)],
          status: OrderStatus.delivered,
          daysAgo: 20,
        ),
      ];
    }

    _persistOrders();
    _persistAddresses();
  }

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
      '${_random.nextInt(0xFFFF).toRadixString(36)}';

  /// Türkçe karakterlere duyarlı küçük harfe çevirme (İ→i, I→ı).
  String _fold(String input) =>
      input.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

  // ---------------------------------------------------------------- auth

  UserModel login(String email, String password) {
    final match = _users.where(
      (u) => _fold(u['email'] as String) == _fold(email.trim()),
    );
    if (match.isEmpty || match.first['password'] != password) {
      throw const ValidationException('E-posta veya şifre hatalı.');
    }
    return UserModel.fromJson(match.first);
  }

  UserModel register({
    required String name,
    required String email,
    required String password,
  }) {
    final exists = _users.any(
      (u) => _fold(u['email'] as String) == _fold(email.trim()),
    );
    if (exists) {
      throw const ValidationException(
        'Bu e-posta ile kayıtlı bir hesap zaten var.',
      );
    }
    final user = {
      'id': _newId('u'),
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'role': 'customer',
    };
    _users.add(user);
    _persistExtraUsers();
    return UserModel.fromJson(user);
  }

  UserModel? userById(String id) {
    final match = _users.where((u) => u['id'] == id);
    return match.isEmpty ? null : UserModel.fromJson(match.first);
  }

  void _persistExtraUsers() {
    final seedIds = _seedUsers.map((u) => u['id']).toSet();
    final extras =
        _users.where((u) => !seedIds.contains(u['id'])).toList();
    _store.setJson(_kExtraUsers, extras);
  }

  // ------------------------------------------------------------- catalog

  List<CategoryModel> getCategories() => List.unmodifiable(_categories);

  ProductModel productById(String id) {
    final match = _products.where((p) => p.id == id);
    if (match.isEmpty) {
      throw const NotFoundException('Ürün bulunamadı veya satıştan kalktı.');
    }
    return match.first;
  }

  ProductPage queryProducts(ProductQuery query) {
    var results = _products.where((p) {
      if (query.categoryId != null && p.categoryId != query.categoryId) {
        return false;
      }
      if (query.q != null && query.q!.trim().isNotEmpty) {
        final needle = _fold(query.q!.trim());
        final haystack = _fold('${p.name} ${p.brand} ${p.seller}');
        if (!haystack.contains(needle)) return false;
      }
      if (query.minPrice != null && p.price < query.minPrice!) return false;
      if (query.maxPrice != null && p.price > query.maxPrice!) return false;
      if (query.minRating != null && p.rating < query.minRating!) return false;
      if (query.inStockOnly && !p.inStock) return false;
      if (query.flashDealsOnly && !p.isFlashDeal) return false;
      if (query.featuredOnly && !p.isFeatured) return false;
      return true;
    }).toList();

    results.sort(switch (query.sort) {
      ProductSort.featured => (a, b) {
          final featured = (b.isFeatured ? 1 : 0) - (a.isFeatured ? 1 : 0);
          return featured != 0 ? featured : b.rating.compareTo(a.rating);
        },
      ProductSort.priceAsc => (a, b) => a.price.compareTo(b.price),
      ProductSort.priceDesc => (a, b) => b.price.compareTo(a.price),
      ProductSort.ratingDesc => (a, b) => b.rating.compareTo(a.rating),
      ProductSort.newest => (a, b) => b.createdAt.compareTo(a.createdAt),
      ProductSort.discount => (a, b) =>
          b.discountPercent.compareTo(a.discountPercent),
    });

    final totalItems = results.length;
    final totalPages = totalItems == 0 ? 1 : (totalItems / query.size).ceil();
    final start = (query.page - 1) * query.size;
    final items = start >= totalItems
        ? <ProductModel>[]
        : results.sublist(start, min(start + query.size, totalItems));

    return ProductPage(
      items: items,
      page: query.page,
      totalPages: totalPages,
      totalItems: totalItems,
    );
  }

  List<ReviewModel> reviewsFor(String productId) {
    final list = _reviews.where((r) => r.productId == productId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  ReviewModel addReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  }) {
    final review = ReviewModel(
      id: _newId('r'),
      productId: productId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.add(review);
    // Yalnızca sonradan eklenen yorumları persist et (seed zaten asset'te);
    // _newId "r-" önekiyle ürettiği için seed kayıtlardan ayırt edilebilir.
    final extras = _reviews
        .where((r) => r.id.startsWith('r-'))
        .map((r) => r.toJson())
        .toList();
    _store.setJson(_kExtraReviews, extras);
    return review;
  }

  // ---------------------------------------------------------------- cart

  Cart getCart() {
    final items = <CartItem>[];
    var changed = false;
    for (final entry in _cartQuantities.entries.toList()) {
      final match = _products.where((p) => p.id == entry.key);
      if (match.isEmpty) {
        // Ürün admin tarafından silinmiş — sepetten düş.
        _cartQuantities.remove(entry.key);
        changed = true;
        continue;
      }
      items.add(CartItem(product: match.first, quantity: entry.value));
    }
    if (changed) _persistCart();

    Coupon? coupon;
    if (_cartCouponCode != null) {
      final match = coupons.where((c) => c.code == _cartCouponCode);
      coupon = match.isEmpty ? null : match.first;
    }
    return Cart(items: items, coupon: coupon);
  }

  Cart addToCart(String productId, int quantity) {
    final product = productById(productId);
    final current = _cartQuantities[productId] ?? 0;
    final requested = current + quantity;
    if (!product.inStock) {
      throw const ValidationException('Bu ürün şu anda stokta yok.');
    }
    if (requested > product.stock) {
      throw ValidationException(
        'Stokta yeterli ürün yok (en fazla ${product.stock} adet).',
      );
    }
    _cartQuantities[productId] = requested;
    _persistCart();
    return getCart();
  }

  Cart updateCartQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeFromCart(productId);
    final product = productById(productId);
    if (quantity > product.stock) {
      throw ValidationException(
        'Stokta yeterli ürün yok (en fazla ${product.stock} adet).',
      );
    }
    _cartQuantities[productId] = quantity;
    _persistCart();
    return getCart();
  }

  Cart removeFromCart(String productId) {
    _cartQuantities.remove(productId);
    if (_cartQuantities.isEmpty) _cartCouponCode = null;
    _persistCart();
    return getCart();
  }

  Cart clearCart() {
    _cartQuantities = {};
    _cartCouponCode = null;
    _persistCart();
    return getCart();
  }

  Cart applyCoupon(String code) {
    final normalized = code.trim().toUpperCase();
    final match = coupons.where((c) => c.code == normalized);
    if (match.isEmpty) {
      throw const ValidationException('Geçersiz kupon kodu.');
    }
    final coupon = match.first;
    final subtotal = getCart().subtotal;
    if (subtotal < coupon.minSubtotal) {
      throw ValidationException(
        'Bu kupon en az ${coupon.minSubtotal.toStringAsFixed(0)} TL '
        'tutarındaki sepetlerde geçerlidir.',
      );
    }
    _cartCouponCode = coupon.code;
    _persistCart();
    return getCart();
  }

  Cart removeCoupon() {
    _cartCouponCode = null;
    _persistCart();
    return getCart();
  }

  void _persistCart() {
    _store.setJson(_kCart, {
      'items': _cartQuantities,
      'coupon': _cartCouponCode,
    });
  }

  // ----------------------------------------------------------- favorites

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<ProductModel> favoriteProducts() =>
      _products.where((p) => _favoriteIds.contains(p.id)).toList();

  Set<String> toggleFavorite(String productId) {
    if (!_favoriteIds.remove(productId)) {
      _favoriteIds.add(productId);
    }
    _store.setJson(_kFavorites, _favoriteIds.toList());
    return favoriteIds;
  }

  // -------------------------------------------------------------- orders

  OrderModel createOrder({
    required String userId,
    required AddressModel address,
    required String cardLast4,
  }) {
    final cart = getCart();
    if (cart.isEmpty) {
      throw const ValidationException('Sepetiniz boş.');
    }
    for (final item in cart.items) {
      if (item.quantity > item.product.stock) {
        throw ValidationException(
          '"${item.product.name}" için stok yetersiz '
          '(kalan: ${item.product.stock}).',
        );
      }
    }

    // Stokları düş.
    for (final item in cart.items) {
      final index = _products.indexWhere((p) => p.id == item.product.id);
      final product = _products[index];
      _products[index] = ProductModel.fromEntity(
        _copyWithStock(product, product.stock - item.quantity),
      );
    }
    _persistProducts();

    final order = OrderModel(
      id: 'VB${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      userId: userId,
      items: cart.items
          .map(
            (item) => OrderItemModel(
              productId: item.product.id,
              name: item.product.name,
              imageUrl: item.product.primaryImage,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
      recipientName: address.fullName,
      addressText: address.summary,
      cardLast4: cardLast4,
      subtotal: cart.subtotal,
      couponDiscount: cart.couponDiscount,
      shippingFee: cart.shippingFee,
      total: cart.grandTotal,
      couponCode: cart.coupon?.code,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    _persistOrders();
    clearCart();
    return order;
  }

  List<OrderModel> ordersFor(String userId) =>
      _orders.where((o) => o.userId == userId).toList();

  List<OrderModel> allOrders() => List.unmodifiable(_orders);

  OrderModel orderById(String id) {
    final match = _orders.where((o) => o.id == id);
    if (match.isEmpty) throw const NotFoundException('Sipariş bulunamadı.');
    return match.first;
  }

  OrderModel updateOrderStatus(String id, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index < 0) throw const NotFoundException('Sipariş bulunamadı.');
    final updated = OrderModel.fromEntity(_copyOrderWithStatus(
      _orders[index],
      status,
    ));
    _orders[index] = updated;
    _persistOrders();
    return updated;
  }

  Order _copyOrderWithStatus(Order order, OrderStatus status) => Order(
        id: order.id,
        userId: order.userId,
        items: order.items,
        recipientName: order.recipientName,
        addressText: order.addressText,
        cardLast4: order.cardLast4,
        subtotal: order.subtotal,
        couponDiscount: order.couponDiscount,
        shippingFee: order.shippingFee,
        total: order.total,
        couponCode: order.couponCode,
        status: status,
        createdAt: order.createdAt,
      );

  void _persistOrders() {
    _store.setJson(_kOrders, _orders.map((o) => o.toJson()).toList());
  }

  // ----------------------------------------------------------- addresses

  List<AddressModel> addressesFor(String userId) =>
      List.unmodifiable(_addressesByUser[userId] ?? const []);

  AddressModel saveAddress(String userId, AddressModel address) {
    final list = _addressesByUser.putIfAbsent(userId, () => []);
    final saved = address.id.isEmpty
        ? AddressModel(
            id: _newId('a'),
            title: address.title,
            fullName: address.fullName,
            phone: address.phone,
            city: address.city,
            district: address.district,
            addressLine: address.addressLine,
          )
        : address;
    final index = list.indexWhere((a) => a.id == saved.id);
    if (index >= 0) {
      list[index] = saved;
    } else {
      list.add(saved);
    }
    _persistAddresses();
    return saved;
  }

  void deleteAddress(String userId, String addressId) {
    _addressesByUser[userId]?.removeWhere((a) => a.id == addressId);
    _persistAddresses();
  }

  void _persistAddresses() {
    _store.setJson(
      _kAddresses,
      _addressesByUser.map(
        (userId, list) =>
            MapEntry(userId, list.map((a) => a.toJson()).toList()),
      ),
    );
  }

  // --------------------------------------------------------------- admin

  ProductModel upsertProduct(ProductModel product) {
    final saved = product.id.isEmpty
        ? ProductModel.fromEntity(_copyWithId(product, _newId('p')))
        : product;
    final index = _products.indexWhere((p) => p.id == saved.id);
    if (index >= 0) {
      _products[index] = saved;
    } else {
      _products.insert(0, saved);
    }
    _persistProducts();
    return saved;
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _cartQuantities.remove(productId);
    _favoriteIds.remove(productId);
    _persistProducts();
    _persistCart();
    _store.setJson(_kFavorites, _favoriteIds.toList());
  }

  Map<OrderStatus, int> _statusBreakdown() {
    final map = <OrderStatus, int>{};
    for (final order in _orders) {
      map[order.status] = (map[order.status] ?? 0) + 1;
    }
    return map;
  }

  ({
    double totalRevenue,
    int orderCount,
    int productCount,
    int customerCount,
    int outOfStockCount,
    Map<OrderStatus, int> statusBreakdown,
  }) stats() {
    final revenue = _orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold<double>(0, (sum, o) => sum + o.total);
    return (
      totalRevenue: revenue,
      orderCount: _orders.length,
      productCount: _products.length,
      customerCount: _users.where((u) => u['role'] == 'customer').length,
      outOfStockCount: _products.where((p) => !p.inStock).length,
      statusBreakdown: _statusBreakdown(),
    );
  }

  void _persistProducts() {
    _store.setJson(_kProducts, _products.map((p) => p.toJson()).toList());
  }

  ProductModel _copyWithId(ProductModel p, String id) => ProductModel(
        id: id,
        name: p.name,
        brand: p.brand,
        description: p.description,
        categoryId: p.categoryId,
        price: p.price,
        originalPrice: p.originalPrice,
        images: p.images,
        rating: p.rating,
        reviewCount: p.reviewCount,
        stock: p.stock,
        seller: p.seller,
        freeShipping: p.freeShipping,
        isFlashDeal: p.isFlashDeal,
        isFeatured: p.isFeatured,
        createdAt: p.createdAt,
      );

  ProductModel _copyWithStock(ProductModel p, int stock) => ProductModel(
        id: p.id,
        name: p.name,
        brand: p.brand,
        description: p.description,
        categoryId: p.categoryId,
        price: p.price,
        originalPrice: p.originalPrice,
        images: p.images,
        rating: p.rating,
        reviewCount: p.reviewCount,
        stock: stock,
        seller: p.seller,
        freeShipping: p.freeShipping,
        isFlashDeal: p.isFlashDeal,
        isFeatured: p.isFeatured,
        createdAt: p.createdAt,
      );
}
