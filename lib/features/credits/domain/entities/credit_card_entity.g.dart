// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditCardEntity _$CreditCardEntityFromJson(Map<String, dynamic> json) =>
    _CreditCardEntity(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      creditLimit: (json['creditLimit'] as num).toDouble(),
      statementDay: (json['statementDay'] as num).toInt(),
      paymentDueDays: (json['paymentDueDays'] as num).toInt(),
      interestRateAnnual: (json['interestRateAnnual'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$CreditCardEntityToJson(_CreditCardEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'creditLimit': instance.creditLimit,
      'statementDay': instance.statementDay,
      'paymentDueDays': instance.paymentDueDays,
      'interestRateAnnual': instance.interestRateAnnual,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
