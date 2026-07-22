import 'package:json_annotation/json_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.description,
    required super.categoryId,
    required super.price,
    super.originalPrice,
    required super.images,
    required super.rating,
    required super.reviewCount,
    required super.stock,
    required super.seller,
    super.freeShipping,
    super.isFlashDeal,
    super.isFeatured,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Cart/Favorites gibi özet uçlarının döndürdüğü kısaltılmış ürün JSON'u
  /// (`{id, title, price, stock, photoId, sellerId?, sellerName?, ...}`)
  /// için esnek dönüştürücü — tam katalog kaydı değil, satır görünümü.
  factory ProductModel.fromSummaryJson(Map<String, dynamic> json) {
    final photoId = json['photoId'] as String?;
    final seller = json['seller'] as Map<String, dynamic>?;
    return ProductModel(
      id: (json['id'] ?? json['productId']).toString(),
      name: (json['title'] ?? json['name'] ?? '').toString(),
      brand: '',
      description: (json['description'] ?? '').toString(),
      categoryId:
          (json['categoryId'] ?? (json['category'] as Map?)?['id'] ?? '')
              .toString(),
      price: (json['price'] as num).toDouble(),
      images: photoId != null
          ? ['${AppConfig.apiBaseUrl}/photos/$photoId']
          : const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num).toInt(),
      seller: (json['sellerName'] ?? seller?['storeName'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  factory ProductModel.fromEntity(Product p) => ProductModel(
        id: p.id,
        name: p.name,
        brand: p.brand,
        description: p.description,
        categoryId: p.categoryId,
        price: p.price,
        originalPrice: p.originalPrice,
        images: p.images,
        rating: p.rating,
        reviewCount: p.reviewCount,
        stock: p.stock,
        seller: p.seller,
        freeShipping: p.freeShipping,
        isFlashDeal: p.isFlashDeal,
        isFeatured: p.isFeatured,
        createdAt: p.createdAt,
      );

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
