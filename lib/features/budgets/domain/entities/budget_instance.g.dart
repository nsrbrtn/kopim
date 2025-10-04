// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetInstance _$BudgetInstanceFromJson(Map<String, dynamic> json) =>
    _BudgetInstance(
      id: json['id'] as String,
      budgetId: json['budgetId'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      status: BudgetInstanceStatusX.fromStorage(json['status'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BudgetInstanceToJson(_BudgetInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'budgetId': instance.budgetId,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'amount': instance.amount,
      'spent': instance.spent,
      'status': _statusToJson(instance.status),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
