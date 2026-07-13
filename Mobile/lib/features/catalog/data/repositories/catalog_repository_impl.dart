import '../../../../core/config/app_config.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_mock_data_source.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required CatalogMockDataSource mock,
    required CatalogRemoteDataSource remote,
  })  : _mock = mock,
        _remote = remote;

  final CatalogMockDataSource _mock;
  final CatalogRemoteDataSource _remote;

  @override
  Future<List<Category>> getCategories() =>
      AppConfig.useMock ? _mock.getCategories() : _remote.getCategories();

  @override
  Future<ProductPage> getProducts(ProductQuery query) =>
      AppConfig.useMock ? _mock.getProducts(query) : _remote.getProducts(query);

  @override
  Future<Product> getProduct(String id) =>
      AppConfig.useMock ? _mock.getProduct(id) : _remote.getProduct(id);

  @override
  Future<List<Review>> getReviews(String productId) => AppConfig.useMock
      ? _mock.getReviews(productId)
      : _remote.getReviews(productId);

  @override
  Future<Review> addReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  }) =>
      AppConfig.useMock
          ? _mock.addReview(
              productId: productId,
              userName: userName,
              rating: rating,
              comment: comment,
            )
          : _remote.addReview(
              productId: productId,
              userName: userName,
              rating: rating,
              comment: comment,
            );
}
