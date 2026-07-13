import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_database.dart';
import '../../domain/entities/product_query.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

/// Katalog verilerini [MockDatabase]'ten okur; gerçekçi loading durumları
/// için yapay gecikme ekler.
class CatalogMockDataSource {
  CatalogMockDataSource(this._db);

  final MockDatabase _db;

  Future<T> _withLatency<T>(T Function() action) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return action();
  }

  Future<List<CategoryModel>> getCategories() =>
      _withLatency(_db.getCategories);

  Future<ProductPage> getProducts(ProductQuery query) =>
      _withLatency(() => _db.queryProducts(query));

  Future<ProductModel> getProduct(String id) =>
      _withLatency(() => _db.productById(id));

  Future<List<ReviewModel>> getReviews(String productId) =>
      _withLatency(() => _db.reviewsFor(productId));

  Future<ReviewModel> addReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  }) =>
      _withLatency(
        () => _db.addReview(
          productId: productId,
          userName: userName,
          rating: rating,
          comment: comment,
        ),
      );
}
