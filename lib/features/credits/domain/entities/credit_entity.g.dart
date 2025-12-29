// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditEntity _$CreditEntityFromJson(Map<String, dynamic> json) =>
    _CreditEntity(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      termMonths: (json['termMonths'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$CreditEntityToJson(_CreditEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'categoryId': instance.categoryId,
      'totalAmount': instance.totalAmount,
      'interestRate': instance.interestRate,
      'termMonths': instance.termMonths,
      'startDate': instance.startDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
