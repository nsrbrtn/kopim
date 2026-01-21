import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_amount_converter.dart';
import 'package:kopim/core/money/money_utils.dart';

import 'saving_goal_category_breakdown.dart';

part 'saving_goal_analytics.freezed.dart';
part 'saving_goal_analytics.g.dart';

@freezed
abstract class SavingGoalAnalytics with _$SavingGoalAnalytics {
  // ignore: unused_element
  const SavingGoalAnalytics._();

  const factory SavingGoalAnalytics({
    required String goalId,
    @MoneyAmountJsonConverter() required MoneyAmount totalAmount,
    DateTime? lastContributionAt,
    @Default(<SavingGoalCategoryBreakdown>[])
    List<SavingGoalCategoryBreakdown> categoryBreakdown,
    @Default(0) int transactionCount,
  }) = _SavingGoalAnalytics;

  factory SavingGoalAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalAnalyticsFromJson(json);
}
