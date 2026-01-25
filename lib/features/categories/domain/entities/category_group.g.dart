// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryGroup _$CategoryGroupFromJson(Map<String, dynamic> json) =>
    _CategoryGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$CategoryGroupToJson(_CategoryGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
