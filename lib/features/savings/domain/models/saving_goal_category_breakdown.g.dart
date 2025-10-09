// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal_category_breakdown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingGoalCategoryBreakdown _$SavingGoalCategoryBreakdownFromJson(
  Map<String, dynamic> json,
) => _SavingGoalCategoryBreakdown(
  categoryId: json['categoryId'] as String?,
  amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$SavingGoalCategoryBreakdownToJson(
  _SavingGoalCategoryBreakdown instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'amount': instance.amount,
};
