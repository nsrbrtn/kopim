// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Budget _$BudgetFromJson(Map<String, dynamic> json) => _Budget(
  id: json['id'] as String,
  title: json['title'] as String,
  period: BudgetPeriodX.fromStorage(json['period'] as String?),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  scope: BudgetScopeX.fromStorage(json['scope'] as String?),
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  accounts:
      (json['accounts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  categoryAllocations:
      (json['categoryAllocations'] as List<dynamic>?)
          ?.map(
            (e) => BudgetCategoryAllocation.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <BudgetCategoryAllocation>[],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$BudgetToJson(_Budget instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'period': _periodToJson(instance.period),
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'scope': _scopeToJson(instance.scope),
  'categories': instance.categories,
  'accounts': instance.accounts,
  'categoryAllocations': instance.categoryAllocations,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isDeleted': instance.isDeleted,
};
