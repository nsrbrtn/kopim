import 'package:freezed_annotation/freezed_annotation.dart';

part 'saving_goal_category_breakdown.freezed.dart';
part 'saving_goal_category_breakdown.g.dart';

@freezed
abstract class SavingGoalCategoryBreakdown with _$SavingGoalCategoryBreakdown {
  const SavingGoalCategoryBreakdown._();

  const factory SavingGoalCategoryBreakdown({
    String? categoryId,
    @Default(0.0) double amount,
  }) = _SavingGoalCategoryBreakdown;

  factory SavingGoalCategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalCategoryBreakdownFromJson(json);
}
