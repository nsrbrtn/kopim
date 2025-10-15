// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_category_allocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetCategoryAllocation _$BudgetCategoryAllocationFromJson(
  Map<String, dynamic> json,
) => _BudgetCategoryAllocation(
  categoryId: json['categoryId'] as String,
  limit: (json['limit'] as num).toDouble(),
);

Map<String, dynamic> _$BudgetCategoryAllocationToJson(
  _BudgetCategoryAllocation instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'limit': instance.limit,
};
