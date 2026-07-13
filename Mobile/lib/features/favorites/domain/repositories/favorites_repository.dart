import '../../../catalog/domain/entities/product.dart';

abstract interface class FavoritesRepository {
  Future<Set<String>> getFavoriteIds();

  Future<List<Product>> getFavorites();

  /// Ekli değilse ekler, ekliyse çıkarır; güncel id kümesini döner.
  Future<Set<String>> toggleFavorite(String productId);
}
