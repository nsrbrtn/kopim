import 'package:kopim/core/money/money_utils.dart';

class OverviewDailyAllowance {
  const OverviewDailyAllowance({
    required this.dailyAllowance,
    required this.daysLeft,
    required this.horizonDate,
    required this.disposableAtHorizon,
    required this.plannedIncome,
    required this.plannedExpense,
    required this.hasIncomeAnchor,
  });

  final MoneyAmount dailyAllowance;
  final int daysLeft;
  final DateTime horizonDate;
  final MoneyAmount disposableAtHorizon;
  final MoneyAmount plannedIncome;
  final MoneyAmount plannedExpense;
  final bool hasIncomeAnchor;

  bool get isNegative => dailyAllowance.minor < BigInt.zero;
}
