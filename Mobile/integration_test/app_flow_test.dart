import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vbshop/app.dart';
import 'package:vbshop/core/di/core_providers.dart';
import 'package:vbshop/core/mock/mock_database.dart';
import 'package:vbshop/core/storage/local_store.dart';
import 'package:vbshop/core/storage/token_store.dart';

/// Testin cihazın gerçek Keystore/DPAPI deposuna dokunmaması için
/// bellek-içi token deposu.
class _InMemoryTokenStore extends TokenStore {
  String? _access;
  String? _refresh;
  String? _userId;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<String?> readUserId() async => _userId;

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
    _userId = userId;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _userId = null;
  }
}

/// Mock gecikmeleri ve geçiş animasyonları gerçek zamanda aktığı için
/// pumpAndSettle yerine hedef görünene kadar pompalayan yardımcı.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Widget bulunamadı: $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'kritik akış: ara → detay → sepet + kupon → login → checkout → sipariş',
    (tester) async {
      // Masaüstünde DPI ölçekleme test koordinatlarını kaydırdığı için
      // sabit bir telefon viewport'u simüle et (390x844 mantıksal).
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      Intl.defaultLocale = 'tr_TR';
      await initializeDateFormatting('tr_TR');

      final prefs = await SharedPreferences.getInstance();
      final store = LocalStore(prefs);
      final db = MockDatabase(store);
      await db.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStoreProvider.overrideWithValue(store),
            mockDatabaseProvider.overrideWithValue(db),
            tokenStoreProvider.overrideWithValue(_InMemoryTokenStore()),
          ],
          child: const VBShopApp(),
        ),
      );

      // Splash → ana sayfa
      await pumpUntilFound(tester, find.textContaining('Süper Fırsatlar'));

      // Arama ekranı
      await tester.tap(find.text('Ürün, kategori veya marka ara'));
      await pumpUntilFound(tester, find.text('Popüler Aramalar'));
      await tester.enterText(find.byType(TextField).first, 'iphone');
      await tester.testTextInput.receiveAction(TextInputAction.search);

      // Sonuç listesi → ürün detayı (kart ekran dışındaysa önce görünür yap)
      final productTile = find.textContaining('iPhone 16', findRichText: true);
      await pumpUntilFound(tester, productTile);
      await tester.ensureVisible(productTile.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(productTile.first);

      // Detay → sepete ekle
      final addToCart = find.widgetWithText(ElevatedButton, 'Sepete Ekle');
      await pumpUntilFound(tester, addToCart);
      await tester.tap(addToCart);
      await pumpUntilFound(tester, find.textContaining('sepete eklendi'));
      // SnackBar kapanana kadar bekle — alttaki butonları örtmesin.
      await tester.pump(const Duration(milliseconds: 4500));

      // Masaüstü test ortamında overlay (SnackBar/AppBar) hit-test'i
      // güvenilmez olduğundan rotalardan programatik pop ile çık;
      // ardından alt menüden Sepetim'e geç.
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pump(const Duration(milliseconds: 600));
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Sepetim').hitTestable().first);
      await pumpUntilFound(tester, find.text('Sepeti Onayla'));

      // Kupon uygula
      await tester.enterText(find.byType(TextField).first, 'VB10');
      await tester.tap(find.text('Uygula'));
      await pumpUntilFound(tester, find.textContaining('%10'));

      // Checkout — misafir olduğumuz için login guard devreye girmeli.
      // (Masaüstü test ortamında hayalet SnackBar kopyası footer'ı
      // bloke edebildiği için buton yerine router kullanılır; guard yine
      // router redirect'i üzerinden test edilir.)
      final cartContext = tester.element(find.text('Sepeti Onayla'));
      GoRouter.of(cartContext).push('/checkout');
      await pumpUntilFound(tester, find.text('Demo hesaplarıyla hızlı giriş'));

      // Login: formu doldur, klavye aksiyonuyla gönder
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'demo@vbshop.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'demo123');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Login sonrası checkout'a dönmeli (redirect parametresi)
      await pumpUntilFound(tester, find.text('Teslimat Adresi'));
      await pumpUntilFound(tester, find.text('Ev'));
      await tester.ensureVisible(find.text('Ev').first);
      await tester.tap(find.text('Ev').first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.byKey(const Key('checkout-continue-0')));
      await tester.tap(find.byKey(const Key('checkout-continue-0')));
      await tester.pump(const Duration(milliseconds: 600));

      // Ödeme formu (simülasyon)
      await tester.enterText(
        find.byKey(const Key('checkout-card-number')),
        '4242424242424242',
      );
      await tester.enterText(
        find.byKey(const Key('checkout-card-holder')),
        'Demo Kullanıcı',
      );
      await tester.enterText(find.byKey(const Key('checkout-expiry')), '1229');
      await tester.enterText(find.byKey(const Key('checkout-cvv')), '123');
      await tester.ensureVisible(find.byKey(const Key('checkout-continue-1')));
      await tester.tap(find.byKey(const Key('checkout-continue-1')));
      await pumpUntilFound(tester, find.text('Ödenecek Tutar'));

      // Siparişi tamamla
      await tester.ensureVisible(find.byKey(const Key('checkout-continue-2')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('checkout-continue-2')));
      await pumpUntilFound(tester, find.textContaining('Siparişin Alındı'));
      expect(find.textContaining('Sipariş No'), findsWidgets);

      // Sipariş geçmişinde yeni sipariş "Onay Bekliyor" olarak görünmeli
      await tester.tap(find.text('Siparişlerime Git'));
      await pumpUntilFound(tester, find.text('Onay Bekliyor'));
    },
  );
}
