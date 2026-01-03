// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionTagEntity _$TransactionTagEntityFromJson(
  Map<String, dynamic> json,
) => _TransactionTagEntity(
  transactionId: json['transactionId'] as String,
  tagId: json['tagId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$TransactionTagEntityToJson(
  _TransactionTagEntity instance,
) => <String, dynamic>{
  'transactionId': instance.transactionId,
  'tagId': instance.tagId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isDeleted': instance.isDeleted,
};
