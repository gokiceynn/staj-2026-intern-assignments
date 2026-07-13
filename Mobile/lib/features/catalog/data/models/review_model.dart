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

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
