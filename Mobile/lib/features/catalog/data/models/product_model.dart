import 'package:json_annotation/json_annotation.dart';

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
