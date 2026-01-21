import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'home_overview_summary.freezed.dart';

@freezed
abstract class HomeTopExpenseCategory with _$HomeTopExpenseCategory {
  const factory HomeTopExpenseCategory({
    required String? categoryId,
    required MoneyAmount amount,
  }) = _HomeTopExpenseCategory;
}

@freezed
abstract class HomeOverviewSummary with _$HomeOverviewSummary {
  const factory HomeOverviewSummary({
    required MoneyAmount totalBalance,
    required MoneyAmount todayIncome,
    required MoneyAmount todayExpense,
    HomeTopExpenseCategory? topExpenseCategory,
  }) = _HomeOverviewSummary;
}
