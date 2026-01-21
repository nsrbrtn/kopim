// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_category_allocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetCategoryAllocation _$BudgetCategoryAllocationFromJson(
  Map<String, dynamic> json,
) => _BudgetCategoryAllocation(
  categoryId: json['categoryId'] as String,
  limitMinor: const BigIntJsonConverter().fromJson(
    _readLimitMinor(json, 'limitMinor') as String,
  ),
  limitScale: (_readLimitScale(json, 'limitScale') as num).toInt(),
);

Map<String, dynamic> _$BudgetCategoryAllocationToJson(
  _BudgetCategoryAllocation instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'limitMinor': _writeLimitMinor(instance.limitMinor),
  'limitScale': _writeLimitScale(instance.limitScale),
};
