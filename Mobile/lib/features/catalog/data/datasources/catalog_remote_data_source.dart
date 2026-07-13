import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/product_query.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

/// Gerçek API katalog uçları. Sözleşme beklentisi:
/// `GET /products?q=&category=&minPrice=&maxPrice=&sort=&page=&size=`
/// → `{ "items": [...], "page": 1, "totalPages": 5, "totalItems": 96 }`
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
          .map(CategoryModel.fromJson)
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
      final data = response.data!;
      return ProductPage(
        items: (data['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(ProductModel.fromJson)
            .toList(),
        page: data['page'] as int,
        totalPages: data['totalPages'] as int,
        totalItems: data['totalItems'] as int,
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
      return ProductModel.fromJson(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<List<ReviewModel>> getReviews(String productId) async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        ApiEndpoints.productReviews(productId),
      );
      return response.data!
          .cast<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
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
      // userName sunucuda token'dan çözülür; body'de gönderilmez.
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.productReviews(productId),
        data: {'rating': rating, 'comment': comment},
      );
      return ReviewModel.fromJson(response.data!);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
