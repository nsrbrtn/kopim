import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_group_link.freezed.dart';
part 'category_group_link.g.dart';

@freezed
abstract class CategoryGroupLink with _$CategoryGroupLink {
  const CategoryGroupLink._();

  const factory CategoryGroupLink({
    required String groupId,
    required String categoryId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _CategoryGroupLink;

  factory CategoryGroupLink.fromJson(Map<String, Object?> json) =>
      _$CategoryGroupLinkFromJson(json);
}
