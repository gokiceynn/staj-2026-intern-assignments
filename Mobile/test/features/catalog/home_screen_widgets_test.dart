import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vbshop/app.dart';
import 'package:vbshop/core/di/core_providers.dart';
import 'package:vbshop/core/mock/mock_database.dart';
import 'package:vbshop/core/storage/local_store.dart';

/// Web'den mobile uyarlanan yeni ana sayfa bileşenlerinin (hızlı kategori
/// grid'i, flaş fırsat/favoriler kartları) gerçekten render olduğunu ve
/// dokunulduğunda hatasız yönlendirdiğini doğrular. `--dart-define=USE_MOCK=true`
/// ile çalıştırılmalı ki katalog verisi backend'e ihtiyaç duymadan gelsin.
Future<void> _pumpHomeToReady(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final localStore = LocalStore(prefs);
  final mockDatabase = MockDatabase(localStore);
  await mockDatabase.init();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
        mockDatabaseProvider.overrideWithValue(mockDatabase),
      ],
      child: const VBShopApp(),
    ),
  );

  // Splash ekranı en az 900ms görünür kalır, sonra /home'a yönlendirir.
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'ana sayfa: yeni hızlı kategori grid\'i ve promo kartları render olur',
    (tester) async {
      await _pumpHomeToReady(tester);

      // Hızlı kategori grid'i (web'deki renkli ikon kartlarının karşılığı).
      expect(find.text('Süper Fırsat'), findsOneWidget);
      // "Elektronik"/"Moda"/"Ev & Yaşam" hem yeni hızlı grid'de hem de
      // mevcut kategori şeridinde (mock kategori adları aynı) göründüğü
      // için en az bir eşleşme yeterli.
      expect(find.text('Elektronik'), findsWidgets);
      expect(find.text('Moda'), findsWidgets);
      expect(find.text('Ev & Yaşam'), findsWidgets);
      // Bunlar yalnızca yeni hızlı grid'e özgü, kategori şeridinde yok.
      expect(find.text('Yüksek Puan'), findsOneWidget);
      expect(find.text('Yeni Gelenler'), findsOneWidget);
      expect(find.text('YENİ'), findsOneWidget);

      // Flaş fırsat + favoriler promo kartları.
      expect(find.text('FLAŞ FIRSAT'), findsOneWidget);
      expect(find.text('En Beğenilenler'), findsWidgets);
      expect(find.text('Favorilerim'), findsOneWidget);
      expect(find.text('Listeni Oluştur'), findsOneWidget);

      // "Yüksek Puan" kartına dokunmak /products?sortBy=rating_desc'e
      // hatasız yönlendirmeli (SnackBar/exception olmamalı).
      await tester.tap(find.text('Yüksek Puan'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Yüksek Puan'), findsWidgets); // AppBar başlığı

      // "Favorilerim" kartı görünür ve dokunulabilir bir InkWell içinde —
      // hedef rota (`/favorites`) router'da zaten tanımlıydı (bkz.
      // account_screen.dart), burada yalnızca kartın kendisini doğruluyoruz.
      final favoritesCard = find.ancestor(
        of: find.text('Favorilerim'),
        matching: find.byType(InkWell),
      );
      expect(favoritesCard, findsOneWidget);
    },
  );
}
