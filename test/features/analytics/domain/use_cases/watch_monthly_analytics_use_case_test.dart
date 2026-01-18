import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._controller);

  final StreamController<List<TransactionEntity>> _controller;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _controller.stream;

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    throw UnimplementedError();
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

class _FakeCategoryRepository implements CategoryRepository {
  _FakeCategoryRepository(this._controller);

  final StreamController<List<Category>> _controller;

  @override
  Stream<List<Category>> watchCategories() => _controller.stream;

  @override
  Stream<List<CategoryTreeNode>> watchCategoryTree() {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> loadCategories() {
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryTreeNode>> loadCategoryTree() {
    throw UnimplementedError();
  }

  @override
  Future<Category?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Category?> findByName(String name) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(Category category) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }
}

void main() {
  test('analytics uses minor units when provided', () async {
    final StreamController<List<TransactionEntity>> txController =
        StreamController<List<TransactionEntity>>();
    final StreamController<List<Category>> categoryController =
        StreamController<List<Category>>();

    final WatchMonthlyAnalyticsUseCase useCase = WatchMonthlyAnalyticsUseCase(
      transactionRepository: _FakeTransactionRepository(txController),
      categoryRepository: _FakeCategoryRepository(categoryController),
    );

    final AnalyticsFilter filter = AnalyticsFilter(
      start: DateTime(2024, 1, 1),
      end: DateTime(2024, 2, 1),
    );

    final Future<AnalyticsOverview> future = useCase.call(
      filter: filter,
      topCategoriesLimit: 5,
    ).first;

    categoryController.add(const <Category>[]);
    txController.add(<TransactionEntity>[
      TransactionEntity(
        id: 't1',
        accountId: 'acc-1',
        amount: 1.0,
        amountMinor: BigInt.from(150),
        amountScale: 2,
        date: DateTime(2024, 1, 10),
        type: TransactionType.income.storageValue,
        createdAt: DateTime(2024, 1, 10),
        updatedAt: DateTime(2024, 1, 10),
      ),
      TransactionEntity(
        id: 't2',
        accountId: 'acc-1',
        amount: 0.1,
        amountMinor: BigInt.from(25),
        amountScale: 2,
        date: DateTime(2024, 1, 12),
        type: TransactionType.expense.storageValue,
        createdAt: DateTime(2024, 1, 12),
        updatedAt: DateTime(2024, 1, 12),
      ),
    ]);

    final AnalyticsOverview overview = await future;

    expect(overview.totalIncome, closeTo(1.5, 1e-9));
    expect(overview.totalExpense, closeTo(0.25, 1e-9));
    expect(overview.netBalance, closeTo(1.25, 1e-9));

    await txController.close();
    await categoryController.close();
  });
}
