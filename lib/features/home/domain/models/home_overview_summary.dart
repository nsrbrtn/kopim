import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_overview_summary.freezed.dart';

@freezed
abstract class HomeTopExpenseCategory with _$HomeTopExpenseCategory {
  const factory HomeTopExpenseCategory({
    required String? categoryId,
    required double amount,
  }) = _HomeTopExpenseCategory;
}

@freezed
abstract class HomeOverviewSummary with _$HomeOverviewSummary {
  const factory HomeOverviewSummary({
    required double totalBalance,
    required double todayIncome,
    required double todayExpense,
    HomeTopExpenseCategory? topExpenseCategory,
  }) = _HomeOverviewSummary;
}
