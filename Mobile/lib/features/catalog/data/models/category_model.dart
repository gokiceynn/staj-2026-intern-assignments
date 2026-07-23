import 'package:json_annotation/json_annotation.dart';

import '../../../../features/catalog/presentation/widgets/category_visuals.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
  });

  /// Mock veri (`assets/data/categories.json`) bu şekli kullanır —
  /// `{id, name, icon}` düz alanlar.
  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  /// Gerçek API şeması (`CategoryNode`): `{id, name, slug, iconId,
  /// parentCategoryId, productCount, children}` — ikon anahtarı yok,
  /// `slug`'a göre en yakın ikon eşlenir.
  factory CategoryModel.fromCategoryNode(Map<String, dynamic> json) {
    final slug = (json['slug'] ?? '').toString();
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      icon: iconKeyForSlug(slug),
    );
  }

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
