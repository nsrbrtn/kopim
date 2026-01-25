// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_group_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryGroupLink _$CategoryGroupLinkFromJson(Map<String, dynamic> json) =>
    _CategoryGroupLink(
      groupId: json['groupId'] as String,
      categoryId: json['categoryId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$CategoryGroupLinkToJson(_CategoryGroupLink instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'categoryId': instance.categoryId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
