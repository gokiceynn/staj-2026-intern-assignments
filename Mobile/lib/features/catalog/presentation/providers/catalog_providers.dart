import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/datasources/catalog_mock_data_source.dart';
import '../../data/datasources/catalog_remote_data_source.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepositoryImpl(
    mock: CatalogMockDataSource(ref.watch(mockDatabaseProvider)),
    remote: CatalogRemoteDataSource(ref.watch(dioClientProvider)),
  );
});

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(catalogRepositoryProvider).getCategories(),
);

final productDetailProvider = FutureProvider.family<Product, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).getProduct(id),
);

final reviewsProvider = FutureProvider.family<List<Review>, String>(
  (ref, productId) => ref.watch(catalogRepositoryProvider).getReviews(productId),
);

/// Ana sayfa: süper fırsatlar rayı.
final flashDealsProvider = FutureProvider<List<Product>>((ref) async {
  final page = await ref.watch(catalogRepositoryProvider).getProducts(
        const ProductQuery(
          flashDealsOnly: true,
          sort: ProductSort.discount,
          size: 12,
        ),
      );
  return page.items;
});

/// Ana sayfa: öne çıkanlar rayı.
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final page = await ref.watch(catalogRepositoryProvider).getProducts(
        const ProductQuery(featuredOnly: true, size: 12),
      );
  return page.items;
});

/// Ana sayfa: en beğenilenler grid'i.
final topRatedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final page = await ref.watch(catalogRepositoryProvider).getProducts(
        const ProductQuery(sort: ProductSort.ratingDesc, size: 6),
      );
  return page.items;
});

/// Ürün detayında "Benzer Ürünler" rayı.
final similarProductsProvider = FutureProvider.family<List<Product>,
    ({String categoryId, String excludeId})>((ref, args) async {
  final page = await ref.watch(catalogRepositoryProvider).getProducts(
        ProductQuery(categoryId: args.categoryId, size: 8),
      );
  return page.items.where((p) => p.id != args.excludeId).toList();
});

/// Sayfalanmış ürün listesi durumu (sonsuz kaydırma).
class PaginatedProducts {
  const PaginatedProducts({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
    this.loadingMore = false,
  });

  final List<Product> items;
  final int page;
  final int totalPages;
  final int totalItems;
  final bool loadingMore;

  bool get hasMore => page < totalPages;

  PaginatedProducts copyWith({bool? loadingMore}) => PaginatedProducts(
        items: items,
        page: page,
        totalPages: totalPages,
        totalItems: totalItems,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Liste ekranının controller'ı: ilk sayfayı yükler, [loadMore] ile
/// sonraki sayfaları ekler. UI yalnızca state izler — iş mantığı burada.
final productListProvider = AsyncNotifierProvider.family<ProductListController,
    PaginatedProducts, ProductQuery>(ProductListController.new);

class ProductListController extends AsyncNotifier<PaginatedProducts> {
  ProductListController(this.query);

  final ProductQuery query;

  @override
  Future<PaginatedProducts> build() async {
    final page = await ref.watch(catalogRepositoryProvider).getProducts(query);
    return PaginatedProducts(
      items: page.items,
      page: page.page,
      totalPages: page.totalPages,
      totalItems: page.totalItems,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref
          .read(catalogRepositoryProvider)
          .getProducts(query.withPage(current.page + 1));
      state = AsyncData(
        PaginatedProducts(
          items: [...current.items, ...next.items],
          page: next.page,
          totalPages: next.totalPages,
          totalItems: next.totalItems,
        ),
      );
    } catch (_) {
      // Sayfa yükleme hatasında mevcut listeyi koru; kullanıcı tekrar dener.
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}

/// Arama geçmişi — cihaz-yerel bir UX verisi olduğu için doğrudan
/// LocalStore'da tutulur (mock/remote moddan bağımsız).
final searchHistoryProvider =
    NotifierProvider<SearchHistoryController, List<String>>(
  SearchHistoryController.new,
);

class SearchHistoryController extends Notifier<List<String>> {
  static const _key = 'app.search_history';

  @override
  List<String> build() {
    final raw = ref.watch(localStoreProvider).getJson(_key);
    return raw is List ? raw.map((e) => e.toString()).toList() : [];
  }

  void add(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      trimmed,
      ...state.where((t) => t.toLowerCase() != trimmed.toLowerCase()),
    ].take(10).toList();
    state = updated;
    ref.read(localStoreProvider).setJson(_key, updated);
  }

  void remove(String term) {
    state = state.where((t) => t != term).toList();
    ref.read(localStoreProvider).setJson(_key, state);
  }

  void clear() {
    state = [];
    ref.read(localStoreProvider).setJson(_key, state);
  }
}
