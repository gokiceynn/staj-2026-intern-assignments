import '../../../../core/config/app_config.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../datasources/favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({
    required FavoritesLocalDataSource local,
    required FavoritesRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final FavoritesLocalDataSource _local;
  final FavoritesRemoteDataSource _remote;

  @override
  Future<Set<String>> getFavoriteIds() =>
      AppConfig.useMock ? _local.getFavoriteIds() : _remote.getFavoriteIds();

  @override
  Future<List<Product>> getFavorites() =>
      AppConfig.useMock ? _local.getFavorites() : _remote.getFavorites();

  @override
  Future<Set<String>> toggleFavorite(String productId) => AppConfig.useMock
      ? _local.toggleFavorite(productId)
      : _remote.toggleFavorite(productId);
}
