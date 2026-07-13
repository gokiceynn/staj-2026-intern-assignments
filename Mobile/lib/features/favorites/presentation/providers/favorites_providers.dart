import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../data/datasources/favorites_local_data_source.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepositoryImpl(
    FavoritesLocalDataSource(ref.watch(mockDatabaseProvider)),
  ),
);

/// Favori ürün id kümesi — kalp ikonları bunu izler.
final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, Set<String>>(
  FavoritesController.new,
);

class FavoritesController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() =>
      ref.watch(favoritesRepositoryProvider).getFavoriteIds();

  Future<void> toggle(String productId) async {
    final ids =
        await ref.read(favoritesRepositoryProvider).toggleFavorite(productId);
    state = AsyncData(ids);
  }
}

/// Favoriler ekranındaki ürün listesi; id kümesi değişince yenilenir.
final favoriteProductsProvider = FutureProvider<List<Product>>((ref) {
  ref.watch(favoritesControllerProvider);
  return ref.watch(favoritesRepositoryProvider).getFavorites();
});
