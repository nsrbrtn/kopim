import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_analytics.dart';
import 'package:kopim/features/savings/domain/use_cases/watch_saving_goal_analytics_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
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
  Future<List<TransactionEntity>> loadTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findById(String id) {
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
        amount: -50,
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
        amount: 75,
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
        amount: 20,
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
      expect(analytics.totalAmount, closeTo(125, 0.0001));
      expect(analytics.lastContributionAt, secondDate);
      expect(analytics.categoryBreakdown, hasLength(2));
      expect(analytics.categoryBreakdown.first.categoryId, 'salary');
      expect(analytics.categoryBreakdown.first.amount, closeTo(75, 0.0001));
      expect(analytics.categoryBreakdown.last.categoryId, 'food');
      expect(analytics.categoryBreakdown.last.amount, closeTo(50, 0.0001));
    });
  });
}
