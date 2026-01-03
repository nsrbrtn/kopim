import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
abstract class TagEntity with _$TagEntity {
  const TagEntity._();

  const factory TagEntity({
    required String id,
    required String name,
    required String color,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _TagEntity;

  factory TagEntity.fromJson(Map<String, Object?> json) =>
      _$TagEntityFromJson(json);
}
