import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    required String id,
    required String name,
    required String type,
    PhosphorIconDescriptor? icon,
    String? color,
    String? parentId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
    @Default(false) bool isSystem,
  }) = _Category;

  factory Category.fromJson(Map<String, Object?> json) =>
      _$CategoryFromJson(json);
}
