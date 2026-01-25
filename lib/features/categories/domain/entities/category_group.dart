import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_group.freezed.dart';
part 'category_group.g.dart';

@freezed
abstract class CategoryGroup with _$CategoryGroup {
  const CategoryGroup._();

  const factory CategoryGroup({
    required String id,
    required String name,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _CategoryGroup;

  factory CategoryGroup.fromJson(Map<String, Object?> json) =>
      _$CategoryGroupFromJson(json);
}
