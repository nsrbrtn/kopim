import 'package:collection/collection.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_analytics.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

import 'saving_goals_controller.dart';
import 'saving_goals_state.dart';

part 'saving_goal_details_providers.g.dart';

class SavingGoalForecast {
  const SavingGoalForecast({
    required this.averageMonthlyContribution,
    this.estimatedCompletionDate,
    required this.recommendedMonthlyContribution,
  });

  final double averageMonthlyContribution;
  final DateTime? estimatedCompletionDate;
  final double recommendedMonthlyContribution;
}

double _calculateRecommendedMonthlyContribution({
  required double remainingAmount,
  required DateTime? targetDate,
  required DateTime now,
}) {
  if (remainingAmount <= 0 || targetDate == null || !targetDate.isAfter(now)) {
    return 0;
  }

  final int daysUntilTarget = targetDate.difference(now).inDays;
  if (daysUntilTarget <= 30) {
    return remainingAmount;
  }

  final double monthsUntilTarget = daysUntilTarget / 30.44;
  if (monthsUntilTarget <= 0.1) {
    return remainingAmount;
  }

  return remainingAmount / monthsUntilTarget;
}

@riverpod
SavingGoal? savingGoalById(Ref ref, String goalId) {
  final List<SavingGoal> goals = ref.watch(
    savingGoalsControllerProvider.select(
      (SavingGoalsState state) => state.goals,
    ),
  );
  return goals.firstWhereOrNull((SavingGoal goal) => goal.id == goalId);
}

@riverpod
Stream<SavingGoalAnalytics> savingGoalAnalytics(Ref ref, String goalId) {
  return ref
      .watch(watchSavingGoalAnalyticsUseCaseProvider)
      .call(goalId: goalId);
}

@riverpod
Stream<List<Category>> savingGoalCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}

@riverpod
Stream<List<TransactionEntity>> savingGoalTransactions(Ref ref, String goalId) {
  return ref.watch(transactionRepositoryProvider).watchTransactions().map((
    List<TransactionEntity> transactions,
  ) {
    return transactions
        .where((TransactionEntity t) => t.savingGoalId == goalId)
        .toList();
  });
}

@riverpod
SavingGoalForecast? savingGoalForecast(Ref ref, String goalId) {
  final SavingGoal? goal = ref.watch(savingGoalByIdProvider(goalId));
  if (goal == null) {
    return null;
  }

  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    savingGoalTransactionsProvider(goalId),
  );
  final List<TransactionEntity> transactions =
      transactionsAsync.value ?? const <TransactionEntity>[];

  if (transactions.isEmpty) {
    final DateTime now = DateTime.now();
    final double recommended = _calculateRecommendedMonthlyContribution(
      remainingAmount: goal.remainingAmount / 100,
      targetDate: goal.targetDate,
      now: now,
    );
    return SavingGoalForecast(
      averageMonthlyContribution: 0,
      estimatedCompletionDate: null,
      recommendedMonthlyContribution: recommended,
    );
  }

  double totalAmount = 0;
  DateTime? firstTxDate;
  for (final TransactionEntity tx in transactions) {
    final double amount = tx.amountValue.abs().toDouble();
    totalAmount += amount;
    if (firstTxDate == null || tx.date.isBefore(firstTxDate)) {
      firstTxDate = tx.date;
    }
  }

  final DateTime now = DateTime.now();
  final int daysPassed = now.difference(firstTxDate!).inDays;
  final int effectiveDays = daysPassed < 1 ? 1 : daysPassed;
  final double dailyAverage = totalAmount / effectiveDays;
  final double averageMonthly = dailyAverage * 30.44;

  DateTime? estimatedDate;
  final double remaining = goal.remainingAmount / 100;
  if (remaining > 0 && dailyAverage > 0) {
    final double daysRemaining = remaining / dailyAverage;
    if (daysRemaining < 36500) {
      estimatedDate = now.add(Duration(days: daysRemaining.round()));
    }
  }

  final double recommended = _calculateRecommendedMonthlyContribution(
    remainingAmount: remaining,
    targetDate: goal.targetDate,
    now: now,
  );

  return SavingGoalForecast(
    averageMonthlyContribution: averageMonthly,
    estimatedCompletionDate: estimatedDate,
    recommendedMonthlyContribution: recommended,
  );
}

@riverpod
Stream<List<AccountEntity>> savingGoalAccounts(Ref ref, String goalId) {
  final SavingGoal? goal = ref.watch(savingGoalByIdProvider(goalId));
  if (goal == null) {
    return Stream<List<AccountEntity>>.value(const <AccountEntity>[]);
  }

  final List<String> storageIds = goal.effectiveStorageAccountIds;
  if (storageIds.isEmpty) {
    return Stream<List<AccountEntity>>.value(const <AccountEntity>[]);
  }

  return ref.watch(watchAccountsUseCaseProvider).call().map((
    List<AccountEntity> accounts,
  ) {
    return accounts
        .where((AccountEntity account) => storageIds.contains(account.id))
        .toList();
  });
}
