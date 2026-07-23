import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.categoryId,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.seller,
    this.freeShipping = false,
    this.isFlashDeal = false,
    this.isFeatured = false,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String brand;
  final String description;
  final String categoryId;

  /// Güncel satış fiyatı.
  final double price;

  /// İndirim öncesi fiyat; indirim yoksa null.
  final double? originalPrice;

  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stock;
  final String seller;
  final bool freeShipping;
  final bool isFlashDeal;
  final bool isFeatured;
  final DateTime createdAt;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent =>
      hasDiscount ? (100 * (1 - price / originalPrice!)).round() : 0;

  bool get inStock => stock > 0;

  /// "Son X ürün" rozeti için eşik.
  bool get lowStock => stock > 0 && stock <= 5;

  String get primaryImage => images.isNotEmpty ? images.first : '';

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        description,
        categoryId,
        price,
        originalPrice,
        images,
        rating,
        reviewCount,
        stock,
        seller,
        freeShipping,
        isFlashDeal,
        isFeatured,
        createdAt,
      ];
}
