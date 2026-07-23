import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/core_providers.dart';
import 'core/mock/mock_database.dart';
import 'core/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // tr_TR para/tarih biçimlendirmesi.
  Intl.defaultLocale = 'tr_TR';
  await initializeDateFormatting('tr_TR');

  final prefs = await SharedPreferences.getInstance();
  final localStore = LocalStore(prefs);

  // Sahte sunucu: seed verisini yükler, kalıcı durumu geri getirir.
  // USE_MOCK=false olsa bile init ucuzdur ve favoriler gibi cihaz-yerel
  // özellikler için kullanılır.
  final mockDatabase = MockDatabase(localStore);
  await mockDatabase.init();

  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
        mockDatabaseProvider.overrideWithValue(mockDatabase),
      ],
      child: const VBShopApp(),
    ),
  );
}
