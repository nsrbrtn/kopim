// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionEntity _$TransactionEntityFromJson(Map<String, dynamic> json) =>
    _TransactionEntity(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      transferAccountId: json['transferAccountId'] as String?,
      categoryId: json['categoryId'] as String?,
      savingGoalId: json['savingGoalId'] as String?,
      idempotencyKey: json['idempotencyKey'] as String?,
      groupId: json['groupId'] as String?,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$TransactionEntityToJson(_TransactionEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'transferAccountId': instance.transferAccountId,
      'categoryId': instance.categoryId,
      'savingGoalId': instance.savingGoalId,
      'idempotencyKey': instance.idempotencyKey,
      'groupId': instance.groupId,
      'date': instance.date.toIso8601String(),
      'note': instance.note,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
