import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';

part 'analytics_overview.freezed.dart';

@freezed
abstract class AnalyticsOverview with _$AnalyticsOverview {
  const AnalyticsOverview._();

  const factory AnalyticsOverview({
    required double totalIncome,
    required double totalExpense,
    required double netBalance,
    required List<AnalyticsCategoryBreakdown> topExpenseCategories,
    required List<AnalyticsCategoryBreakdown> topIncomeCategories,
  }) = _AnalyticsOverview;
}
