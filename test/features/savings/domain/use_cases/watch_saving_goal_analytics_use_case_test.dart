import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_analytics.dart';
import 'package:kopim/features/savings/domain/use_cases/watch_saving_goal_analytics_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._controller);

  final StreamController<List<TransactionEntity>> _controller;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _controller.stream;

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    return _controller.stream.map((List<TransactionEntity> items) {
      if (limit == null || limit >= items.length) {
        return items;
      }
      return items.take(limit).toList(growable: false);
    });
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    return const Stream<List<AccountMonthlyTotals>>.empty();
  }

  @override
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) => const Stream<List<TransactionCategoryTotals>>.empty();

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyCashflowTotals>>.empty();

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyBalanceTotals>>.empty();

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<BudgetExpenseTotals>>.empty();

  @override
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<TransactionEntity>>.empty();

  @override
  Future<List<TransactionEntity>> loadTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findLatestByCategoryId(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findByIdempotencyKey(String idempotencyKey) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('WatchSavingGoalAnalyticsUseCase', () {
    late StreamController<List<TransactionEntity>> controller;
    late WatchSavingGoalAnalyticsUseCase useCase;

    setUp(() {
      controller = StreamController<List<TransactionEntity>>.broadcast();
      useCase = WatchSavingGoalAnalyticsUseCase(
        transactionRepository: _FakeTransactionRepository(controller),
      );
    });

    tearDown(() async {
      await controller.close();
    });

    test('aggregates transactions linked to the goal', () async {
      final DateTime firstDate = DateTime(2024, 1, 10);
      final DateTime secondDate = DateTime(2024, 2, 5);

      final TransactionEntity goalExpense = TransactionEntity(
        id: 't1',
        accountId: 'acc',
        categoryId: 'food',
        savingGoalId: 'goal',
        amountMinor: BigInt.from(-5000),
        amountScale: 2,
        date: firstDate,
        note: null,
        type: TransactionType.expense.storageValue,
        createdAt: firstDate,
        updatedAt: firstDate,
        isDeleted: false,
      );
      final TransactionEntity goalIncome = TransactionEntity(
        id: 't2',
        accountId: 'acc',
        categoryId: 'salary',
        savingGoalId: 'goal',
        amountMinor: BigInt.from(7500),
        amountScale: 2,
        date: secondDate,
        note: null,
        type: TransactionType.income.storageValue,
        createdAt: secondDate,
        updatedAt: secondDate,
        isDeleted: false,
      );
      final TransactionEntity unrelated = TransactionEntity(
        id: 't3',
        accountId: 'acc',
        categoryId: 'other',
        savingGoalId: 'other-goal',
        amountMinor: BigInt.from(2000),
        amountScale: 2,
        date: firstDate,
        note: null,
        type: TransactionType.income.storageValue,
        createdAt: firstDate,
        updatedAt: firstDate,
        isDeleted: false,
      );

      final Future<SavingGoalAnalytics> result = useCase(goalId: 'goal').first;

      controller.add(<TransactionEntity>[goalExpense, goalIncome, unrelated]);

      final SavingGoalAnalytics analytics = await result;
      expect(analytics.goalId, 'goal');
      expect(analytics.transactionCount, 2);
      expect(analytics.totalAmount, _amount(125));
      expect(analytics.lastContributionAt, secondDate);
      expect(analytics.categoryBreakdown, hasLength(2));
      expect(analytics.categoryBreakdown.first.categoryId, 'salary');
      expect(analytics.categoryBreakdown.first.amount, _amount(75));
      expect(analytics.categoryBreakdown.last.categoryId, 'food');
      expect(analytics.categoryBreakdown.last.amount, _amount(50));
    });
  });
}

MoneyAmount _amount(num value, {int scale = 2}) {
  final double scaled = value * 100;
  return MoneyAmount(minor: BigInt.from(scaled.round()), scale: scale);
}
