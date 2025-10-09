import 'package:freezed_annotation/freezed_annotation.dart';

import 'saving_goal_category_breakdown.dart';

part 'saving_goal_analytics.freezed.dart';
part 'saving_goal_analytics.g.dart';

@freezed
abstract class SavingGoalAnalytics with _$SavingGoalAnalytics {
  const SavingGoalAnalytics._();

  const factory SavingGoalAnalytics({
    required String goalId,
    @Default(0.0) double totalAmount,
    DateTime? lastContributionAt,
    @Default(<SavingGoalCategoryBreakdown>[])
    List<SavingGoalCategoryBreakdown> categoryBreakdown,
    @Default(0) int transactionCount,
  }) = _SavingGoalAnalytics;

  factory SavingGoalAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalAnalyticsFromJson(json);
}
