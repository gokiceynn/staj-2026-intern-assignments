import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../catalog/data/models/product_model.dart';

/// Gerçek API favori uçları (`ShoppingController`).
/// `GET /favorites` → `PagedResult<ProductCard>` (`{ items, page, pageSize, totalCount }`).
/// Backend "favori mi" bilgisini tekil sorgulamadığından, toggle için önce
/// mevcut favori id kümesi çekilip üyeliğe göre ekle/çıkar kararı verilir.
class FavoritesRemoteDataSource {
  FavoritesRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<ProductModel>> getFavorites() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.favorites,
        queryParameters: {'page': 1, 'size': 100},
      );
      return (response.data!['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(ProductModel.fromSummaryJson)
          .toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<Set<String>> getFavoriteIds() async {
    final favorites = await getFavorites();
    return favorites.map((p) => p.id).toSet();
  }

  Future<Set<String>> toggleFavorite(String productId) async {
    try {
      final ids = await getFavoriteIds();
      if (ids.contains(productId)) {
        await _client.dio.delete<void>(ApiEndpoints.favorite(productId));
        ids.remove(productId);
      } else {
        await _client.dio.post<void>(ApiEndpoints.favorite(productId));
        ids.add(productId);
      }
      return ids;
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
