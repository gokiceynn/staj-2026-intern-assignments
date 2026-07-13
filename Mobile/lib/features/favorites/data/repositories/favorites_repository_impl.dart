import '../../../catalog/domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  Future<Set<String>> getFavoriteIds() => _local.getFavoriteIds();

  @override
  Future<List<Product>> getFavorites() => _local.getFavorites();

  @override
  Future<Set<String>> toggleFavorite(String productId) =>
      _local.toggleFavorite(productId);
}
