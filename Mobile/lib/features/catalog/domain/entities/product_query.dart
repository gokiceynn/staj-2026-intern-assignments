import 'package:equatable/equatable.dart';

import 'product.dart';

enum ProductSort {
  featured('Önerilen'),
  priceAsc('En Düşük Fiyat'),
  priceDesc('En Yüksek Fiyat'),
  ratingDesc('En Yüksek Puan'),
  newest('En Yeniler'),
  discount('İndirim Oranı');

  const ProductSort(this.label);

  final String label;
}

/// Ürün listeleme/arama/filtreleme parametreleri.
/// API sözleşmesindeki `?q=&category=&minPrice=&maxPrice=&sort=&page=&size=`
/// query string'ine birebir karşılık gelir.
class ProductQuery extends Equatable {
  const ProductQuery({
    this.q,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.inStockOnly = false,
    this.flashDealsOnly = false,
    this.featuredOnly = false,
    this.sort = ProductSort.featured,
    this.page = 1,
    this.size = 20,
  });

  final String? q;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool inStockOnly;
  final bool flashDealsOnly;
  final bool featuredOnly;
  final ProductSort sort;
  final int page;
  final int size;

  /// Null geçilen alanlar korunur; filtre temizlemek için yeni bir
  /// [ProductQuery] kurun (FilterSheet bunu yapar).
  ProductQuery copyWith({
    String? q,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? inStockOnly,
    bool? flashDealsOnly,
    bool? featuredOnly,
    ProductSort? sort,
    int? page,
    int? size,
  }) =>
      ProductQuery(
        q: q ?? this.q,
        categoryId: categoryId ?? this.categoryId,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        minRating: minRating ?? this.minRating,
        inStockOnly: inStockOnly ?? this.inStockOnly,
        flashDealsOnly: flashDealsOnly ?? this.flashDealsOnly,
        featuredOnly: featuredOnly ?? this.featuredOnly,
        sort: sort ?? this.sort,
        page: page ?? this.page,
        size: size ?? this.size,
      );

  ProductQuery withPage(int newPage) => ProductQuery(
        q: q,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        inStockOnly: inStockOnly,
        flashDealsOnly: flashDealsOnly,
        featuredOnly: featuredOnly,
        sort: sort,
        page: newPage,
        size: size,
      );

  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      minRating != null ||
      inStockOnly;

  /// Gerçek API sözleşmesi: `GET /products?q=&categoryId=&minPrice=&
  /// maxPrice=&inStock=&sortBy=&page=&size=`. `minRating`,
  /// `flashDealsOnly`, `featuredOnly` backend'de karşılığı olmayan UI
  /// kavramlarıdır — gönderilmez (bkz. `CatalogRemoteDataSource`).
  /// `sortBy` zorunludur ve yalnızca `price_asc|price_desc|newest|
  /// rating_desc` değerlerini kabul eder.
  Map<String, dynamic> toQueryParameters() => {
        if (q != null && q!.isNotEmpty) 'q': q,
        if (categoryId != null) 'categoryId': categoryId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (inStockOnly) 'inStock': true,
        'sortBy': switch (sort) {
          ProductSort.priceAsc => 'price_asc',
          ProductSort.priceDesc => 'price_desc',
          ProductSort.ratingDesc => 'rating_desc',
          ProductSort.featured || ProductSort.newest || ProductSort.discount =>
            'newest',
        },
        'page': page,
        'size': size,
      };

  @override
  List<Object?> get props => [
        q,
        categoryId,
        minPrice,
        maxPrice,
        minRating,
        inStockOnly,
        flashDealsOnly,
        featuredOnly,
        sort,
        page,
        size,
      ];
}

/// Sayfalanmış ürün sonucu.
class ProductPage extends Equatable {
  const ProductPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });

  final List<Product> items;
  final int page;
  final int totalPages;
  final int totalItems;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [items, page, totalPages, totalItems];
}
