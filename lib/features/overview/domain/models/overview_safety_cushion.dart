import 'package:flutter/foundation.dart';
import 'package:kopim/core/money/money_utils.dart';

enum OverviewSafetyCushionState { risk, unstable, safe }

@immutable
class OverviewSafetyCushion {
  const OverviewSafetyCushion({
    required this.monthsCovered,
    required this.targetMonths,
    required this.progress,
    required this.safetyScore,
    required this.state,
    required this.liquidAssets,
    required this.avgMonthlyExpense,
  });

  final double monthsCovered;
  final double targetMonths;
  final double progress;
  final int safetyScore;
  final OverviewSafetyCushionState state;
  final MoneyAmount liquidAssets;
  final MoneyAmount avgMonthlyExpense;

  bool get hasExpenseBaseline => avgMonthlyExpense.minor > BigInt.zero;
}
