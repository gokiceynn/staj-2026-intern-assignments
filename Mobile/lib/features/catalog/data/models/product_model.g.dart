// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String,
  description: json['description'] as String,
  categoryId: json['categoryId'] as String,
  price: (json['price'] as num).toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  stock: (json['stock'] as num).toInt(),
  seller: json['seller'] as String,
  freeShipping: json['freeShipping'] as bool? ?? false,
  isFlashDeal: json['isFlashDeal'] as bool? ?? false,
  isFeatured: json['isFeatured'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'images': instance.images,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'stock': instance.stock,
      'seller': instance.seller,
      'freeShipping': instance.freeShipping,
      'isFlashDeal': instance.isFlashDeal,
      'isFeatured': instance.isFeatured,
      'createdAt': instance.createdAt.toIso8601String(),
    };
