// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingGoalAnalytics _$SavingGoalAnalyticsFromJson(Map<String, dynamic> json) =>
    _SavingGoalAnalytics(
      goalId: json['goalId'] as String,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      lastContributionAt: json['lastContributionAt'] == null
          ? null
          : DateTime.parse(json['lastContributionAt'] as String),
      categoryBreakdown:
          (json['categoryBreakdown'] as List<dynamic>?)
              ?.map(
                (e) => SavingGoalCategoryBreakdown.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <SavingGoalCategoryBreakdown>[],
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SavingGoalAnalyticsToJson(
  _SavingGoalAnalytics instance,
) => <String, dynamic>{
  'goalId': instance.goalId,
  'totalAmount': instance.totalAmount,
  'lastContributionAt': instance.lastContributionAt?.toIso8601String(),
  'categoryBreakdown': instance.categoryBreakdown,
  'transactionCount': instance.transactionCount,
};
