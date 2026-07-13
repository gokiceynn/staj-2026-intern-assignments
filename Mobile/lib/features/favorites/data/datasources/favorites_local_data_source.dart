import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_database.dart';
import '../../../catalog/data/models/product_model.dart';

/// Favoriler cihaz-yerel tutulur (misafir kullanıcı da favori ekleyebilir).
/// Sunucu senkronizasyonu backend sözleşmesine eklendiğinde repository
/// üzerinden remote kaynağa geçilecek — bkz. README yol haritası.
class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._db);

  final MockDatabase _db;

  Future<T> _withLatency<T>(T Function() action) async {
    await Future<void>.delayed(AppConfig.mockLatency ~/ 2);
    return action();
  }

  Future<Set<String>> getFavoriteIds() =>
      _withLatency(() => _db.favoriteIds);

  Future<List<ProductModel>> getFavorites() =>
      _withLatency(_db.favoriteProducts);

  Future<Set<String>> toggleFavorite(String productId) =>
      _withLatency(() => _db.toggleFavorite(productId));
}
