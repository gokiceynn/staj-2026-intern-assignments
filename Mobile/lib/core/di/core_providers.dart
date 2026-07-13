import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_database.dart';
import '../network/dio_client.dart';
import '../storage/local_store.dart';
import '../storage/token_store.dart';

/// main() içinde gerçek örnekle override edilir (SharedPreferences async
/// başlatma gerektirdiği için).
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('main() içinde override edilmeli'),
);

/// main() içinde init edilmiş örnekle override edilir.
final mockDatabaseProvider = Provider<MockDatabase>(
  (ref) => throw UnimplementedError('main() içinde override edilmeli'),
);

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.watch(tokenStoreProvider)),
);
