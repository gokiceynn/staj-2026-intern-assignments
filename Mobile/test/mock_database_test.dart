import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vbshop/core/error/app_exception.dart';
import 'package:vbshop/core/mock/mock_database.dart';
import 'package:vbshop/core/storage/local_store.dart';
import 'package:vbshop/features/catalog/domain/entities/product_query.dart';
import 'package:vbshop/features/orders/domain/entities/order.dart';
import 'package:vbshop/features/profile/data/models/address_model.dart';

/// Sahte sunucunun (MockDatabase) iş kurallarını doğrular: filtreleme,
/// kupon, stok kontrolü ve sipariş akışı.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDatabase db;

  const testAddress = AddressModel(
    id: 'a-test',
    title: 'Ev',
    fullName: 'Test Kullanıcı',
    phone: '+90 555 111 22 33',
    city: 'İstanbul',
    district: 'Kadıköy',
    addressLine: 'Test Mah. Test Sok. No: 1',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = MockDatabase(LocalStore(prefs));
    await db.init();
  });

  group('Ürün sorgulama', () {
    test('kategori filtresi yalnızca o kategorinin ürünlerini döner', () {
      final page = db.queryProducts(
        const ProductQuery(categoryId: 'elektronik', size: 100),
      );
      expect(page.items, isNotEmpty);
      expect(page.items.every((p) => p.categoryId == 'elektronik'), isTrue);
    });

    test('arama Türkçe karakterlere duyarsız eşleşir', () {
      final page = db.queryProducts(const ProductQuery(q: 'iphone'));
      expect(page.items.any((p) => p.name.contains('iPhone')), isTrue);
    });

    test('fiyat aralığı filtresi çalışır', () {
      final page = db.queryProducts(
        const ProductQuery(minPrice: 100, maxPrice: 1000, size: 100),
      );
      expect(
        page.items.every((p) => p.price >= 100 && p.price <= 1000),
        isTrue,
      );
    });

    test('fiyata göre artan sıralama doğrudur', () {
      final page = db.queryProducts(
        const ProductQuery(sort: ProductSort.priceAsc, size: 100),
      );
      for (var i = 1; i < page.items.length; i++) {
        expect(
          page.items[i].price,
          greaterThanOrEqualTo(page.items[i - 1].price),
        );
      }
    });

    test('sayfalama toplam sayfa sayısını doğru hesaplar', () {
      final page = db.queryProducts(const ProductQuery(size: 10));
      expect(page.items.length, 10);
      expect(page.totalPages, (page.totalItems / 10).ceil());
      expect(page.hasMore, isTrue);
    });
  });

  group('Auth', () {
    test('doğru bilgilerle giriş başarılıdır', () {
      final user = db.login('demo@vbshop.com', 'demo123');
      expect(user.name, 'Demo Kullanıcı');
    });

    test('yanlış şifre ValidationException fırlatır', () {
      expect(
        () => db.login('demo@vbshop.com', 'yanlis'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('aynı e-posta ile ikinci kayıt engellenir', () {
      expect(
        () => db.register(
          name: 'Biri',
          email: 'demo@vbshop.com',
          password: '123456',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Sepet ve kupon', () {
    test('stok üzerinde adet eklenemez', () {
      // p11 seed verisinde 2 adet stoklu.
      db.addToCart('p11', 2);
      expect(
        () => db.addToCart('p11', 1),
        throwsA(isA<ValidationException>()),
      );
    });

    test('geçersiz kupon reddedilir', () {
      db.addToCart('p25', 1);
      expect(
        () => db.applyCoupon('OLMAYANKUPON'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('VB10 kuponu %10 indirim uygular', () {
      db.addToCart('p04', 1); // 14.499 TL
      final cart = db.applyCoupon('vb10'); // küçük harf de kabul edilir
      expect(cart.coupon?.code, 'VB10');
      expect(cart.couponDiscount, closeTo(1449.9, 0.01));
    });

    test('minimum tutar altında HOSGELDIN50 uygulanmaz', () {
      db.addToCart('p25', 1); // 189 TL < 300 TL
      expect(
        () => db.applyCoupon('HOSGELDIN50'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Sipariş akışı', () {
    test('sipariş oluşturunca sepet boşalır ve stok düşer', () {
      final stockBefore = db.productById('p04').stock;
      db.addToCart('p04', 2);

      final order = db.createOrder(
        userId: 'u-demo',
        address: testAddress,
        cardLast4: '4242',
      );

      expect(order.status, OrderStatus.pending);
      expect(order.items.single.quantity, 2);
      expect(db.getCart().isEmpty, isTrue);
      expect(db.productById('p04').stock, stockBefore - 2);
      expect(db.ordersFor('u-demo').first.id, order.id);
    });

    test('boş sepetle sipariş verilemez', () {
      expect(
        () => db.createOrder(
          userId: 'u-demo',
          address: testAddress,
          cardLast4: '4242',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('admin sipariş durumunu güncelleyebilir', () {
      db.addToCart('p25', 1);
      final order = db.createOrder(
        userId: 'u-demo',
        address: testAddress,
        cardLast4: '4242',
      );
      final updated = db.updateOrderStatus(order.id, OrderStatus.shipped);
      expect(updated.status, OrderStatus.shipped);
      expect(db.orderById(order.id).status, OrderStatus.shipped);
    });
  });

  group('Admin ürün yönetimi', () {
    test('ürün silinince sepetten ve favorilerden de kalkar', () {
      db.addToCart('p25', 1);
      db.toggleFavorite('p25');

      db.deleteProduct('p25');

      expect(() => db.productById('p25'), throwsA(isA<NotFoundException>()));
      expect(db.getCart().items.any((i) => i.product.id == 'p25'), isFalse);
      expect(db.favoriteIds.contains('p25'), isFalse);
    });
  });
}
