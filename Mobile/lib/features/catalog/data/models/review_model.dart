import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/review.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.userName,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  /// Mock veri şekli: `{id, productId, userName, rating, comment, createdAt}`.
  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  /// Gerçek API şeması (`ReviewDto`): `{id, productId, user:{id,displayName},
  /// rating, comment, photos, isVerifiedPurchase, createdAt, updatedAt}`.
  factory ReviewModel.fromReviewDto(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'].toString(),
      productId: json['productId'].toString(),
      userName: (user?['displayName'] ?? 'Kullanıcı').toString(),
      rating: (json['rating'] as num).toInt(),
      comment: (json['comment'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
