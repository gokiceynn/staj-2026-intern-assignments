import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, productId, userName, rating, comment, createdAt];
}
