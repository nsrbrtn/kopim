import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/overview/domain/models/financial_index_models.dart';
import 'package:kopim/features/overview/domain/services/behavior_discipline_calculator.dart';
import 'package:kopim/features/overview/domain/services/financial_index_calculator.dart';
import 'package:kopim/features/overview/domain/services/safety_cushion_calculator.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchFinancialIndexUseCase {
  WatchFinancialIndexUseCase({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
    required BudgetRepository budgetRepository,
    required SavingGoalRepository savingGoalRepository,
    ComputeBudgetProgressUseCase? computeBudgetProgressUseCase,
  }) : _accountRepository = accountRepository,
       _transactionRepository = transactionRepository,
       _budgetRepository = budgetRepository,
       _savingGoalRepository = savingGoalRepository,
       _computeBudgetProgressUseCase =
           computeBudgetProgressUseCase ?? ComputeBudgetProgressUseCase();

  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;
  final SavingGoalRepository _savingGoalRepository;
  final ComputeBudgetProgressUseCase _computeBudgetProgressUseCase;

  Stream<FinancialIndexSeries> call({
    DateTime? reference,
    Set<String>? accountIdsFilter,
    Set<String>? categoryIdsFilter,
    int historyMonths = 6,
    FinancialIndexWeights weights = FinancialIndexWeights.standard,
  }) {
    return _combineLatest4(
      _accountRepository.watchAccounts(),
      _transactionRepository.watchTransactions(),
      _budgetRepository.watchBudgets(),
      _savingGoalRepository.watchGoals(includeArchived: false),
      (
        List<AccountEntity> accounts,
        List<TransactionEntity> transactions,
        List<Budget> budgets,
        List<SavingGoal> savingGoals,
      ) {
        return computeFinancialIndexSeries(
          accounts: accounts,
          transactions: transactions,
          budgets: budgets,
          savingGoals: savingGoals,
          reference: reference ?? DateTime.now(),
          historyMonths: historyMonths,
          accountIdsFilter: accountIdsFilter,
          categoryIdsFilter: categoryIdsFilter,
          weights: weights,
          computeBudgetProgressUseCase: _computeBudgetProgressUseCase,
        );
      },
    );
  }
}

@visibleForTesting
FinancialIndexSeries computeFinancialIndexSeries({
  required List<AccountEntity> accounts,
  required List<TransactionEntity> transactions,
  required List<Budget> budgets,
  required List<SavingGoal> savingGoals,
  required DateTime reference,
  required int historyMonths,
  required FinancialIndexWeights weights,
  required ComputeBudgetProgressUseCase computeBudgetProgressUseCase,
  Set<String>? accountIdsFilter,
  Set<String>? categoryIdsFilter,
}) {
  final DateTime currentReference = _dateOnly(reference);
  final List<AccountEntity> scopedAccounts = _scopeAccounts(
    accounts: accounts,
    accountIdsFilter: accountIdsFilter,
  );
  final Set<String> scopedAccountIds = scopedAccounts
      .map((AccountEntity account) => account.id)
      .toSet();
  final List<TransactionEntity> scopedTransactions = _scopeTransactions(
    transactions: transactions,
    accountIds: scopedAccountIds,
    categoryIdsFilter: categoryIdsFilter,
  );

  final int safeHistoryMonths = historyMonths < 1 ? 1 : historyMonths;
  final List<FinancialIndexMonthlyPoint> monthlyPoints =
      <FinancialIndexMonthlyPoint>[];
  FinancialIndexSnapshot? currentSnapshot;

  for (int offset = safeHistoryMonths - 1; offset >= 0; offset -= 1) {
    final DateTime monthStart = DateTime(
      currentReference.year,
      currentReference.month - offset,
    );
    final bool isCurrentMonth =
        monthStart.year == currentReference.year &&
        monthStart.month == currentReference.month;

    final DateTime monthReference = isCurrentMonth
        ? currentReference
        : DateTime(monthStart.year, monthStart.month + 1, 0, 12);

    final FinancialIndexSnapshot snapshot = _computeSnapshotForReferenceMonth(
      accounts: scopedAccounts,
      transactions: scopedTransactions,
      budgets: budgets,
      savingGoals: savingGoals,
      reference: monthReference,
      weights: weights,
      computeBudgetProgressUseCase: computeBudgetProgressUseCase,
      accountIdsFilter: accountIdsFilter,
    );

    monthlyPoints.add(
      FinancialIndexMonthlyPoint(
        month: DateTime(monthStart.year, monthStart.month),
        score: snapshot.totalScore,
      ),
    );

    if (isCurrentMonth) {
      currentSnapshot = snapshot;
    }
  }

  final FinancialIndexSnapshot resolvedCurrent =
      currentSnapshot ??
      _computeSnapshotForReferenceMonth(
        accounts: scopedAccounts,
        transactions: scopedTransactions,
        budgets: budgets,
        savingGoals: savingGoals,
        reference: currentReference,
        weights: weights,
        computeBudgetProgressUseCase: computeBudgetProgressUseCase,
        accountIdsFilter: accountIdsFilter,
      );

  return FinancialIndexSeries(
    current: resolvedCurrent,
    monthly: List<FinancialIndexMonthlyPoint>.unmodifiable(monthlyPoints),
  );
}

FinancialIndexSnapshot _computeSnapshotForReferenceMonth({
  required List<AccountEntity> accounts,
  required List<TransactionEntity> transactions,
  required List<Budget> budgets,
  required List<SavingGoal> savingGoals,
  required DateTime reference,
  required FinancialIndexWeights weights,
  required ComputeBudgetProgressUseCase computeBudgetProgressUseCase,
  required Set<String>? accountIdsFilter,
}) {
  final double budgetScore = _computeBudgetScore(
    budgets: budgets,
    transactions: transactions,
    reference: reference,
    computeBudgetProgressUseCase: computeBudgetProgressUseCase,
    accountIdsFilter: accountIdsFilter,
  );

  final double safetyScore = _computeSafetyScore(
    accounts: accounts,
    transactions: transactions,
    savingGoals: savingGoals,
    reference: reference,
  );

  final double dynamicsScore = _computeDynamicsScore(
    transactions: transactions,
    reference: reference,
  );

  final double disciplineScore = _computeDisciplineScore(
    transactions: transactions,
    reference: reference,
  );

  return FinancialIndexCalculator.calculate(
    factors: FinancialIndexFactors(
      budgetScore: budgetScore,
      safetyScore: safetyScore,
      dynamicsScore: dynamicsScore,
      disciplineScore: disciplineScore,
    ),
    weights: weights,
  );
}

double _computeBudgetScore({
  required List<Budget> budgets,
  required List<TransactionEntity> transactions,
  required DateTime reference,
  required ComputeBudgetProgressUseCase computeBudgetProgressUseCase,
  required Set<String>? accountIdsFilter,
}) {
  final DateTime monthStart = DateTime(reference.year, reference.month);
  final DateTime monthEndExclusive = DateTime(
    reference.year,
    reference.month + 1,
  );
  final List<Budget> activeBudgets = budgets
      .where((Budget budget) {
        if (budget.isDeleted) {
          return false;
        }
        if (budget.startDate.isAfter(
          monthEndExclusive.subtract(const Duration(days: 1)),
        )) {
          return false;
        }
        if (budget.endDate != null && budget.endDate!.isBefore(monthStart)) {
          return false;
        }
        if (accountIdsFilter != null &&
            budget.scope == BudgetScope.byAccount &&
            budget.accounts.isNotEmpty &&
            budget.accounts.toSet().intersection(accountIdsFilter).isEmpty) {
          return false;
        }
        return true;
      })
      .toList(growable: false);

  if (activeBudgets.isEmpty) {
    return 55;
  }

  final MoneyAccumulator planned = MoneyAccumulator();
  final MoneyAccumulator spent = MoneyAccumulator();

  for (final Budget budget in activeBudgets) {
    final MoneyAmount budgetAmount = budget.amountValue.abs();
    planned.add(budgetAmount);

    final BudgetProgress progress = computeBudgetProgressUseCase(
      budget: budget,
      transactions: transactions,
      reference: reference,
    );
    spent.add(progress.spent);
  }

  final double plannedValue = planned.toDouble();
  final double spentValue = spent.toDouble();
  if (plannedValue <= 0) {
    return 55;
  }

  final double overspendRatio =
      math.max(0, spentValue - plannedValue) / math.max(plannedValue, 1);
  final double budgetExecution = _clampDouble(
    100 * (1 - spentValue / math.max(plannedValue, 1)),
    0,
    100,
  );
  return _clampDouble(budgetExecution - overspendRatio * 40, 0, 100);
}

double _computeSafetyScore({
  required List<AccountEntity> accounts,
  required List<TransactionEntity> transactions,
  required List<SavingGoal> savingGoals,
  required DateTime reference,
}) {
  return SafetyCushionCalculator.calculate(
    accounts: accounts,
    transactions: transactions,
    savingGoals: savingGoals,
    reference: reference,
  ).safetyScore.toDouble();
}

double _computeDynamicsScore({
  required List<TransactionEntity> transactions,
  required DateTime reference,
}) {
  final DateTime currentMonthStart = DateTime(reference.year, reference.month);
  final DateTime nextMonthStart = DateTime(reference.year, reference.month + 1);
  final DateTime previousMonthStart = DateTime(
    reference.year,
    reference.month - 1,
  );

  final double currentExpense = _sumExpense(
    transactions: transactions,
    start: currentMonthStart,
    end: nextMonthStart,
  );
  final double previousExpense = _sumExpense(
    transactions: transactions,
    start: previousMonthStart,
    end: currentMonthStart,
  );

  final double deltaScore = previousExpense <= 0
      ? 50
      : _clampDouble(
          50 +
              ((previousExpense - currentExpense) /
                      math.max(previousExpense, 1)) *
                  100,
          0,
          100,
        );

  final List<double> trendExpenses = List<double>.generate(6, (int index) {
    final DateTime start = DateTime(
      reference.year,
      reference.month - (5 - index),
    );
    final DateTime end = DateTime(start.year, start.month + 1);
    return _sumExpense(transactions: transactions, start: start, end: end);
  }, growable: false);

  final double trendSlope = _linearRegressionSlope(trendExpenses);
  final double meanExpense = trendExpenses.isEmpty
      ? 0
      : trendExpenses.reduce((double a, double b) => a + b) /
            trendExpenses.length;
  final double trendSlopeNormalized = meanExpense <= 1
      ? 0
      : _clampDouble(trendSlope / meanExpense, -1, 1);
  final double trendScore = _clampDouble(
    50 + (-trendSlopeNormalized) * 50,
    0,
    100,
  );

  return (deltaScore * 0.6 + trendScore * 0.4).roundToDouble();
}

double _computeDisciplineScore({
  required List<TransactionEntity> transactions,
  required DateTime reference,
}) {
  return BehaviorDisciplineCalculator.calculate(
    transactions: transactions,
    reference: reference,
  ).disciplineScore.toDouble();
}

List<AccountEntity> _scopeAccounts({
  required List<AccountEntity> accounts,
  required Set<String>? accountIdsFilter,
}) {
  return accounts
      .where((AccountEntity account) {
        if (account.isDeleted) {
          return false;
        }
        if (accountIdsFilter == null || accountIdsFilter.isEmpty) {
          return true;
        }
        return accountIdsFilter.contains(account.id);
      })
      .toList(growable: false);
}

List<TransactionEntity> _scopeTransactions({
  required List<TransactionEntity> transactions,
  required Set<String> accountIds,
  required Set<String>? categoryIdsFilter,
}) {
  return transactions
      .where((TransactionEntity transaction) {
        if (transaction.isDeleted) {
          return false;
        }
        if (!accountIds.contains(transaction.accountId)) {
          return false;
        }
        if (categoryIdsFilter == null || categoryIdsFilter.isEmpty) {
          return true;
        }
        final String? categoryId = transaction.categoryId;
        return categoryId != null && categoryIdsFilter.contains(categoryId);
      })
      .toList(growable: false);
}

double _sumExpense({
  required List<TransactionEntity> transactions,
  required DateTime start,
  required DateTime end,
}) {
  final MoneyAccumulator sum = MoneyAccumulator();
  for (final TransactionEntity tx in transactions) {
    if (tx.date.isBefore(start) || !tx.date.isBefore(end)) {
      continue;
    }
    if (tx.type != TransactionType.expense.storageValue) {
      continue;
    }
    sum.add(tx.amountValue.abs());
  }
  return sum.toDouble();
}

double _linearRegressionSlope(List<double> values) {
  if (values.length < 2) {
    return 0;
  }

  double sumX = 0;
  double sumY = 0;
  double sumXY = 0;
  double sumXX = 0;

  for (int i = 0; i < values.length; i += 1) {
    final double x = i.toDouble();
    final double y = values[i];
    sumX += x;
    sumY += y;
    sumXY += x * y;
    sumXX += x * x;
  }

  final double n = values.length.toDouble();
  final double denominator = n * sumXX - sumX * sumX;
  if (denominator == 0) {
    return 0;
  }
  return (n * sumXY - sumX * sumY) / denominator;
}

DateTime _dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

double _clampDouble(double value, double min, double max) {
  return value.clamp(min, max).toDouble();
}

Stream<T> _combineLatest4<A, B, C, D, T>(
  Stream<A> first,
  Stream<B> second,
  Stream<C> third,
  Stream<D> fourth,
  T Function(A a, B b, C c, D d) combiner,
) {
  late final StreamController<T> controller;
  A? latestA;
  B? latestB;
  C? latestC;
  D? latestD;
  bool hasA = false;
  bool hasB = false;
  bool hasC = false;
  bool hasD = false;
  late StreamSubscription<A> subA;
  late StreamSubscription<B> subB;
  late StreamSubscription<C> subC;
  late StreamSubscription<D> subD;

  void emitIfReady() {
    if (hasA && hasB && hasC && hasD) {
      controller.add(
        combiner(latestA as A, latestB as B, latestC as C, latestD as D),
      );
    }
  }

  controller = StreamController<T>(
    onListen: () {
      subA = first.listen((A value) {
        latestA = value;
        hasA = true;
        emitIfReady();
      }, onError: controller.addError);
      subB = second.listen((B value) {
        latestB = value;
        hasB = true;
        emitIfReady();
      }, onError: controller.addError);
      subC = third.listen((C value) {
        latestC = value;
        hasC = true;
        emitIfReady();
      }, onError: controller.addError);
      subD = fourth.listen((D value) {
        latestD = value;
        hasD = true;
        emitIfReady();
      }, onError: controller.addError);
    },
    onCancel: () async {
      await subA.cancel();
      await subB.cancel();
      await subC.cancel();
      await subD.cancel();
    },
  );

  return controller.stream;
}
