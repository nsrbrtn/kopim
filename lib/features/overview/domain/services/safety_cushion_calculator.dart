import 'dart:math' as math;

import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/overview/domain/models/overview_safety_cushion.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class SafetyCushionCalculator {
  const SafetyCushionCalculator._();

  static const double defaultTargetMonths = 6;
  static const double maxMonthsCovered = 12;

  static OverviewSafetyCushion calculate({
    required List<AccountEntity> accounts,
    required List<TransactionEntity> transactions,
    required List<SavingGoal> savingGoals,
    required DateTime reference,
    double targetMonths = defaultTargetMonths,
  }) {
    final MoneyAccumulator liquidAssets = MoneyAccumulator();
    for (final AccountEntity account in accounts) {
      if (account.isDeleted || _isLiabilityType(account.type)) {
        continue;
      }
      liquidAssets.add(account.balanceAmount);
    }

    final MoneyAmount avgMonthlyExpense = _averageMonthlyExpense(
      transactions: transactions,
      reference: reference,
      months: 3,
    );

    final double liquidAssetsValue = liquidAssets.toDouble();
    final double avgMonthlyExpenseValue = avgMonthlyExpense.toDouble();

    if (avgMonthlyExpenseValue <= 0 && liquidAssetsValue <= 0) {
      return OverviewSafetyCushion(
        monthsCovered: 0,
        targetMonths: targetMonths,
        progress: 0,
        safetyScore: 50,
        state: _resolveState(50),
        liquidAssets: MoneyAmount(
          minor: liquidAssets.minor,
          scale: liquidAssets.scale,
        ),
        avgMonthlyExpense: avgMonthlyExpense,
      );
    }

    final double monthsCoveredRaw =
        liquidAssetsValue / math.max(avgMonthlyExpenseValue, 1);
    final double monthsCovered = _clampDouble(
      monthsCoveredRaw,
      0,
      maxMonthsCovered,
    );
    final double reserveProgress = _resolveReserveProgress(
      savingGoals: savingGoals,
      monthsCovered: monthsCovered,
      targetMonths: targetMonths,
    );

    final double coverageScore = _clampDouble(
      (monthsCovered / targetMonths) * 100,
      0,
      100,
    );
    final double goalScore = _clampDouble(reserveProgress * 100, 0, 100);
    final int safetyScore = (coverageScore * 0.7 + goalScore * 0.3)
        .round()
        .clamp(0, 100);

    return OverviewSafetyCushion(
      monthsCovered: monthsCovered,
      targetMonths: targetMonths,
      progress: _clampDouble(monthsCovered / targetMonths, 0, 1),
      safetyScore: safetyScore,
      state: _resolveState(safetyScore),
      liquidAssets: MoneyAmount(
        minor: liquidAssets.minor,
        scale: liquidAssets.scale,
      ),
      avgMonthlyExpense: avgMonthlyExpense,
    );
  }

  static MoneyAmount _averageMonthlyExpense({
    required List<TransactionEntity> transactions,
    required DateTime reference,
    required int months,
  }) {
    final MoneyAccumulator total = MoneyAccumulator();
    for (int i = 0; i < months; i += 1) {
      final DateTime start = DateTime(reference.year, reference.month - i);
      final DateTime end = DateTime(start.year, start.month + 1);
      for (final TransactionEntity tx in transactions) {
        if (tx.date.isBefore(start) || !tx.date.isBefore(end)) {
          continue;
        }
        if (tx.type != TransactionType.expense.storageValue) {
          continue;
        }
        total.add(tx.amountValue.abs());
      }
    }

    if (total.isZero) {
      return MoneyAmount(minor: BigInt.zero, scale: total.scale);
    }

    final BigInt monthsBigInt = BigInt.from(months);
    return MoneyAmount(minor: total.minor ~/ monthsBigInt, scale: total.scale);
  }

  static double _resolveReserveProgress({
    required List<SavingGoal> savingGoals,
    required double monthsCovered,
    required double targetMonths,
  }) {
    final List<SavingGoal> active = savingGoals
        .where((SavingGoal goal) => !goal.isArchived)
        .toList(growable: false);
    if (active.isEmpty) {
      return _clampDouble(monthsCovered / targetMonths, 0, 1);
    }

    int totalTarget = 0;
    int totalCurrent = 0;
    for (final SavingGoal goal in active) {
      totalTarget += goal.targetAmount;
      totalCurrent += goal.currentAmount;
    }

    if (totalTarget <= 0) {
      return _clampDouble(monthsCovered / targetMonths, 0, 1);
    }
    return _clampDouble(totalCurrent / totalTarget, 0, 1);
  }

  static OverviewSafetyCushionState _resolveState(int score) {
    if (score < 40) {
      return OverviewSafetyCushionState.risk;
    }
    if (score < 70) {
      return OverviewSafetyCushionState.unstable;
    }
    return OverviewSafetyCushionState.safe;
  }

  static bool _isLiabilityType(String accountType) {
    final String normalized = accountType.trim().toLowerCase();
    return normalized == 'credit' ||
        normalized == 'credit_card' ||
        normalized == 'debt';
  }

  static double _clampDouble(double value, double min, double max) {
    if (value.isNaN) {
      return min;
    }
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }
}
