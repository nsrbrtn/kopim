import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_amount_converter.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'saving_goal_category_breakdown.freezed.dart';
part 'saving_goal_category_breakdown.g.dart';

@freezed
abstract class SavingGoalCategoryBreakdown with _$SavingGoalCategoryBreakdown {
  // ignore: unused_element
  const SavingGoalCategoryBreakdown._();

  const factory SavingGoalCategoryBreakdown({
    String? categoryId,
    @MoneyAmountJsonConverter() required MoneyAmount amount,
  }) = _SavingGoalCategoryBreakdown;

  factory SavingGoalCategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalCategoryBreakdownFromJson(json);
}
