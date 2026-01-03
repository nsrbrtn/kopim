// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TagEntity _$TagEntityFromJson(Map<String, dynamic> json) => _TagEntity(
  id: json['id'] as String,
  name: json['name'] as String,
  color: json['color'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$TagEntityToJson(_TagEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
