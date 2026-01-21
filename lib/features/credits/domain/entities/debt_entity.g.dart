// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DebtEntity _$DebtEntityFromJson(Map<String, dynamic> json) => _DebtEntity(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  name: json['name'] as String? ?? '',
  dueDate: DateTime.parse(json['dueDate'] as String),
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$DebtEntityToJson(_DebtEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'name': instance.name,
      'dueDate': instance.dueDate.toIso8601String(),
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
