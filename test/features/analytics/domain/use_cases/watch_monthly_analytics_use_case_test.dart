import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

void main() {
  group('WatchMonthlyAnalyticsUseCase', () {
    late FakeTransactionRepository repository;
    late WatchMonthlyAnalyticsUseCase useCase;

    setUp(() {
      repository = FakeTransactionRepository();
      useCase = WatchMonthlyAnalyticsUseCase(transactionRepository: repository);
    });

    tearDown(() async {
      await repository.dispose();
    });

    test('returns zero overview when there are no transactions', () async {
      final Future<AnalyticsOverview> future = useCase.call().first;

      await repository.emit(<TransactionEntity>[]);

      final AnalyticsOverview overview = await future;
      expect(overview.totalIncome, 0);
      expect(overview.totalExpense, 0);
      expect(overview.netBalance, 0);
      expect(overview.topExpenseCategories, isEmpty);
      expect(overview.topIncomeCategories, isEmpty);
    });

    test('applies date range filter', () async {
      final AnalyticsFilter filter = AnalyticsFilter(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 7, 1),
      );
      final Future<AnalyticsOverview> future = useCase
          .call(filter: filter)
          .first;

      await repository.emit(<TransactionEntity>[
        buildTransaction(
          id: 't1',
          accountId: 'acc-1',
          amount: 120,
          date: DateTime(2024, 6, 12),
          categoryId: 'cat-ent',
          type: TransactionType.income,
        ),
        buildTransaction(
          id: 't2',
          accountId: 'acc-1',
          amount: -40,
          date: DateTime(2024, 6, 15),
          categoryId: 'cat-food',
          type: TransactionType.expense,
        ),
        buildTransaction(
          id: 't3',
          accountId: 'acc-1',
          amount: -20,
          date: DateTime(2024, 7, 4),
          categoryId: 'cat-travel',
          type: TransactionType.expense,
        ),
      ]);

      final AnalyticsOverview overview = await future;
      expect(overview.totalIncome, 120);
      expect(overview.totalExpense, 40);
      expect(overview.netBalance, 80);
      expect(overview.topExpenseCategories, hasLength(1));
      expect(overview.topExpenseCategories.first.categoryId, 'cat-food');
      expect(overview.topExpenseCategories.first.amount, 40);
      expect(overview.topIncomeCategories, hasLength(1));
      expect(overview.topIncomeCategories.first.categoryId, 'cat-ent');
      expect(overview.topIncomeCategories.first.amount, 120);
    });

    test('filters by account and category', () async {
      final AnalyticsFilter filter = AnalyticsFilter(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 7, 1),
        accountId: 'acc-2',
        categoryId: 'cat-ent',
      );
      final Future<AnalyticsOverview> future = useCase
          .call(filter: filter)
          .first;

      await repository.emit(<TransactionEntity>[
        buildTransaction(
          id: 't1',
          accountId: 'acc-1',
          amount: 200,
          date: DateTime(2024, 6, 5),
          categoryId: 'cat-ent',
          type: TransactionType.income,
        ),
        buildTransaction(
          id: 't2',
          accountId: 'acc-2',
          amount: 150,
          date: DateTime(2024, 6, 6),
          categoryId: 'cat-ent',
          type: TransactionType.income,
        ),
        buildTransaction(
          id: 't3',
          accountId: 'acc-2',
          amount: -30,
          date: DateTime(2024, 6, 7),
          categoryId: 'cat-ent',
          type: TransactionType.expense,
        ),
        buildTransaction(
          id: 't4',
          accountId: 'acc-2',
          amount: -15,
          date: DateTime(2024, 6, 8),
          categoryId: 'cat-food',
          type: TransactionType.expense,
        ),
      ]);

      final AnalyticsOverview overview = await future;
      expect(overview.totalIncome, 150);
      expect(overview.totalExpense, 30);
      expect(overview.netBalance, 120);
      expect(overview.topExpenseCategories, hasLength(1));
      expect(overview.topExpenseCategories.first.categoryId, 'cat-ent');
      expect(overview.topExpenseCategories.first.amount, 30);
      expect(overview.topIncomeCategories, hasLength(1));
      expect(overview.topIncomeCategories.first.categoryId, 'cat-ent');
      expect(overview.topIncomeCategories.first.amount, 150);
    });
  });
}

TransactionEntity buildTransaction({
  required String id,
  required String accountId,
  required double amount,
  required DateTime date,
  required TransactionType type,
  String? categoryId,
}) {
  return TransactionEntity(
    id: id,
    accountId: accountId,
    categoryId: categoryId,
    amount: amount,
    date: date,
    note: null,
    type: type.storageValue,
    createdAt: date,
    updatedAt: date,
  );
}

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository()
    : _controller = StreamController<List<TransactionEntity>>.broadcast();

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

  Future<void> emit(List<TransactionEntity> transactions) async {
    _controller.add(transactions);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> dispose() async {
    await _controller.close();
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
