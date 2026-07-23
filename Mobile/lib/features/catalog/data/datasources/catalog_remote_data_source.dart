import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/product_query.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

/// Gerçek API katalog uçları.
///
/// `GET /products` → `{ "page": { items, page, pageSize, totalCount,
/// totalPages } }` (`ListProductsResult.Page` sarmalaması nedeniyle bir kat
/// daha iç içe — üstteki `data` zarfının ayrıca bir alt anahtarı var).
/// `sortBy` backend'de zorunlu ve yalnızca `price_asc|price_desc|newest|
/// rating_desc` değerlerini kabul ediyor; ön yüzün "Süper Fırsat/Öne Çıkan"
/// gibi kavramları (`flashDealsOnly`/`featuredOnly`) backend'de karşılığı
/// olmadığından yok sayılır — bkz. `ProductQuery.toQueryParameters`.
class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        ApiEndpoints.categories,
      );
      return response.data!
          .cast<Map<String, dynamic>>()
          .map(CategoryModel.fromCategoryNode)
          .toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<ProductPage> getProducts(ProductQuery query) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.products,
        queryParameters: query.toQueryParameters(),
      );
      final page = response.data!['page'] as Map<String, dynamic>;
      return ProductPage(
        items: (page['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(ProductModel.fromSummaryJson)
            .toList(),
        page: page['page'] as int,
        totalPages: page['totalPages'] as int,
        totalItems: (page['totalCount'] as num).toInt(),
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.product(id),
      );
      return ProductModel.fromSummaryJson(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<List<ReviewModel>> getReviews(String productId) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.productReviews(productId),
        queryParameters: {'page': 1, 'size': 50, 'sortBy': 'newest'},
      );
      final reviewsPage = response.data!['reviews'] as Map<String, dynamic>;
      return (reviewsPage['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(ReviewModel.fromReviewDto)
          .toList();
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<ReviewModel> addReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    try {
      // Kullanıcı adı sunucuda token'dan çözülür; body sadece derecelendirme
      // + yorum + fotoğraf listesi (boş liste de geçerli) alır.
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.productReviews(productId),
        data: {'rating': rating, 'comment': comment, 'photoIds': <String>[]},
      );
      return ReviewModel.fromReviewDto(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
