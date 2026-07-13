import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/product_query.dart';
import '../entities/review.dart';

abstract interface class CatalogRepository {
  Future<List<Category>> getCategories();

  Future<ProductPage> getProducts(ProductQuery query);

  Future<Product> getProduct(String id);

  Future<List<Review>> getReviews(String productId);

  Future<Review> addReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  });
}
