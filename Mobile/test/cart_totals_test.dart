import 'package:flutter_test/flutter_test.dart';
import 'package:vbshop/features/cart/domain/entities/cart.dart';
import 'package:vbshop/features/catalog/domain/entities/product.dart';

Product _product({String id = 'p1', double price = 100, int stock = 10}) =>
    Product(
      id: id,
      name: 'Test Ürünü',
      brand: 'Marka',
      description: 'Açıklama',
      categoryId: 'elektronik',
      price: price,
      images: const [],
      rating: 4.5,
      reviewCount: 10,
      stock: stock,
      seller: 'VBShop',
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('Cart toplam hesapları', () {
    test('boş sepette tüm tutarlar sıfırdır', () {
      const cart = Cart();
      expect(cart.subtotal, 0);
      expect(cart.shippingFee, 0);
      expect(cart.grandTotal, 0);
      expect(cart.totalQuantity, 0);
    });

    test('eşik altındaki sepete kargo ücreti eklenir', () {
      final cart = Cart(
        items: [CartItem(product: _product(price: 100), quantity: 1)],
      );
      expect(cart.subtotal, 100);
      expect(cart.shippingFee, 39.99);
      expect(cart.grandTotal, closeTo(139.99, 0.001));
    });

    test('500 TL ve üzeri sepette kargo bedavadır', () {
      final cart = Cart(
        items: [CartItem(product: _product(price: 250), quantity: 2)],
      );
      expect(cart.subtotal, 500);
      expect(cart.shippingFee, 0);
      expect(cart.grandTotal, 500);
    });

    test('adetler doğru toplanır', () {
      final cart = Cart(
        items: [
          CartItem(product: _product(id: 'a', price: 10), quantity: 3),
          CartItem(product: _product(id: 'b', price: 20), quantity: 2),
        ],
      );
      expect(cart.totalQuantity, 5);
      expect(cart.subtotal, 70);
    });
  });

  group('Kupon kuralları', () {
    const percentCoupon = Coupon(
      code: 'VB10',
      description: '%10 indirim',
      percentOff: 10,
    );
    const fixedCoupon = Coupon(
      code: 'HOSGELDIN50',
      description: '300 TL üzeri 50 TL',
      amountOff: 50,
      minSubtotal: 300,
    );

    test('yüzdesel kupon ara toplam üzerinden hesaplanır', () {
      final cart = Cart(
        items: [CartItem(product: _product(price: 1000), quantity: 1)],
        coupon: percentCoupon,
      );
      expect(cart.couponDiscount, 100);
      expect(cart.shippingFee, 0); // 900 ≥ 500
      expect(cart.grandTotal, 900);
    });

    test('minimum tutarın altında sabit kupon uygulanmaz', () {
      final cart = Cart(
        items: [CartItem(product: _product(price: 200), quantity: 1)],
        coupon: fixedCoupon,
      );
      expect(cart.couponDiscount, 0);
    });

    test('kupon indirimi sepeti eşik altına düşürürse kargo eklenir', () {
      // 520 - 50 = 470 < 500 → kargo ücreti geri gelir.
      final cart = Cart(
        items: [CartItem(product: _product(price: 520), quantity: 1)],
        coupon: fixedCoupon,
      );
      expect(cart.couponDiscount, 50);
      expect(cart.shippingFee, 39.99);
      expect(cart.grandTotal, closeTo(509.99, 0.001));
    });

    test('indirim ara toplamı aşamaz', () {
      const bigCoupon = Coupon(
        code: 'DEV',
        description: 'test',
        amountOff: 10000,
      );
      final cart = Cart(
        items: [CartItem(product: _product(price: 100), quantity: 1)],
        coupon: bigCoupon,
      );
      expect(cart.couponDiscount, 100); // clamp
    });

    test('kargo bedava eşiğine kalan tutar doğru hesaplanır', () {
      final cart = Cart(
        items: [CartItem(product: _product(price: 350), quantity: 1)],
      );
      expect(cart.remainingForFreeShipping, 150);

      final over = Cart(
        items: [CartItem(product: _product(price: 600), quantity: 1)],
      );
      expect(over.remainingForFreeShipping, 0);
    });
  });

  group('Product türetilmiş alanlar', () {
    test('indirim yüzdesi doğru hesaplanır', () {
      final product = Product(
        id: 'p',
        name: 'x',
        brand: 'b',
        description: 'd',
        categoryId: 'c',
        price: 75,
        originalPrice: 100,
        images: const [],
        rating: 4,
        reviewCount: 1,
        stock: 3,
        seller: 's',
        createdAt: DateTime(2026),
      );
      expect(product.hasDiscount, isTrue);
      expect(product.discountPercent, 25);
      expect(product.lowStock, isTrue);
    });

    test('stok 0 ise satışta değildir', () {
      final product = _product(stock: 0);
      expect(product.inStock, isFalse);
      expect(product.lowStock, isFalse);
    });
  });
}
