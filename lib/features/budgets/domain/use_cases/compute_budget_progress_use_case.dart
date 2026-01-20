import 'dart:math' as math;

import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class ComputeBudgetProgressUseCase {
  ComputeBudgetProgressUseCase({BudgetSchedule? schedule})
    : _schedule = schedule ?? const BudgetSchedule();

  final BudgetSchedule _schedule;

  BudgetProgress call({
    required Budget budget,
    required List<TransactionEntity> transactions,
    DateTime? reference,
    BudgetInstance? existingInstance,
  }) {
    final DateTime now = reference ?? DateTime.now();
    final _FilteredTransactions filtered = _filterTransactions(
      budget: budget,
      transactions: transactions,
      reference: now,
    );
    final List<TransactionEntity> scopedTransactions = filtered.transactions;

    final MoneyAccumulator spentAccumulator = MoneyAccumulator();
    for (final TransactionEntity tx in scopedTransactions) {
      if (tx.type == TransactionType.income.storageValue ||
          tx.type == TransactionType.transfer.storageValue) {
        continue;
      }
      spentAccumulator.add(tx.amountValue.abs());
    }

    final MoneyAmount budgetAmount = budget.amountValue;
    final MoneyAmount spent = MoneyAmount(
      minor: spentAccumulator.minor,
      scale: spentAccumulator.scale,
    );
    final MoneyAmount normalizedBudget = rescaleMoneyAmount(
      budgetAmount,
      spent.scale,
    );
    final MoneyAmount remaining = MoneyAmount(
      minor: normalizedBudget.minor - spent.minor,
      scale: spent.scale,
    );
    final double budgetTotal = normalizedBudget.toDouble();
    final double spentValue = spent.toDouble();
    final double utilization = budgetTotal <= 0
        ? (spentValue > 0 ? double.infinity : 0)
        : spentValue / budgetTotal;

    final BudgetInstance instance =
        (existingInstance != null &&
            existingInstance.periodStart.isAtSameMomentAs(
              filtered.period.start,
            ))
        ? existingInstance.copyWith(
            periodEnd: filtered.period.end,
            amountMinor: normalizedBudget.minor,
            spentMinor: spent.minor,
            amountScale: spent.scale,
            status: _schedule.statusFor(
              clock: now,
              start: filtered.period.start,
              end: filtered.period.end,
            ),
            updatedAt: now,
          )
        : BudgetInstance(
            id: _buildInstanceId(budget.id, filtered.period.start),
            budgetId: budget.id,
            periodStart: filtered.period.start,
            periodEnd: filtered.period.end,
            amountMinor: normalizedBudget.minor,
            spentMinor: spent.minor,
            amountScale: spent.scale,
            status: _schedule.statusFor(
              clock: now,
              start: filtered.period.start,
              end: filtered.period.end,
            ),
            createdAt: existingInstance?.createdAt ?? now,
            updatedAt: now,
          );

    return BudgetProgress(
      budget: budget,
      instance: instance,
      spent: spent,
      remaining: remaining,
      utilization: utilization.isFinite
          ? math.max(utilization, 0)
          : double.infinity,
      isExceeded: spent.minor > normalizedBudget.minor,
    );
  }

  List<TransactionEntity> filterTransactions({
    required Budget budget,
    required List<TransactionEntity> transactions,
    DateTime? reference,
  }) {
    return _filterTransactions(
      budget: budget,
      transactions: transactions,
      reference: reference ?? DateTime.now(),
    ).transactions;
  }

  _FilteredTransactions _filterTransactions({
    required Budget budget,
    required List<TransactionEntity> transactions,
    required DateTime reference,
  }) {
    final ({DateTime start, DateTime end}) period = _schedule.periodFor(
      budget: budget,
      reference: reference,
    );
    final List<TransactionEntity> scopedTransactions = transactions
        .where((TransactionEntity tx) => _matchesScope(budget, tx))
        .where(
          (TransactionEntity tx) =>
              !tx.date.isBefore(period.start) && tx.date.isBefore(period.end),
        )
        .toList(growable: false);
    return _FilteredTransactions(
      period: period,
      transactions: scopedTransactions,
    );
  }

  bool _matchesScope(Budget budget, TransactionEntity transaction) {
    switch (budget.scope) {
      case BudgetScope.all:
        return true;
      case BudgetScope.byCategory:
        if (budget.categories.isEmpty) {
          return false;
        }
        final String? categoryId = transaction.categoryId;
        return categoryId != null && budget.categories.contains(categoryId);
      case BudgetScope.byAccount:
        if (budget.accounts.isEmpty) {
          return false;
        }
        return budget.accounts.contains(transaction.accountId);
    }
  }

  String _buildInstanceId(String budgetId, DateTime start) {
    return '$budgetId-${start.toIso8601String()}';
  }
}

class _FilteredTransactions {
  const _FilteredTransactions({
    required this.period,
    required this.transactions,
  });

  final ({DateTime start, DateTime end}) period;
  final List<TransactionEntity> transactions;
}
