import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(
    this._controller, {
    Map<String, String?> rootByCategoryId = const <String, String?>{},
  }) : _rootByCategoryId = rootByCategoryId;

  final StreamController<List<TransactionEntity>> _controller;
  final Map<String, String?> _rootByCategoryId;

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
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) {
    return _controller.stream.map((List<TransactionEntity> transactions) {
      final Map<String?, MoneyAccumulator> income =
          <String?, MoneyAccumulator>{};
      final Map<String?, MoneyAccumulator> expense =
          <String?, MoneyAccumulator>{};
      for (final TransactionEntity tx in transactions) {
        if (tx.date.isBefore(start) || !tx.date.isBefore(end)) {
          continue;
        }
        if (accountIds.isNotEmpty && !accountIds.contains(tx.accountId)) {
          continue;
        }
        if (accountId != null && accountId != tx.accountId) {
          continue;
        }
        final MoneyAmount amount = tx.amountValue.abs();
        if (tx.type == TransactionType.income.storageValue) {
          income.putIfAbsent(tx.categoryId, MoneyAccumulator.new).add(amount);
        } else if (tx.type == TransactionType.expense.storageValue) {
          expense.putIfAbsent(tx.categoryId, MoneyAccumulator.new).add(amount);
        }
      }

      final Set<String?> keys = <String?>{}
        ..addAll(income.keys)
        ..addAll(expense.keys);
      return keys
          .map(
            (String? key) => TransactionCategoryTotals(
              categoryId: key,
              rootCategoryId: key != null ? _rootByCategoryId[key] : null,
              income: _toMoneyAmount(income[key]),
              expense: _toMoneyAmount(expense[key]),
            ),
          )
          .toList(growable: false);
    });
  }

  MoneyAmount _toMoneyAmount(MoneyAccumulator? accumulator) {
    if (accumulator == null) {
      return MoneyAmount(minor: BigInt.zero, scale: 2);
    }
    return MoneyAmount(minor: accumulator.minor, scale: accumulator.scale);
  }

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) {
    throw UnimplementedError();
  }

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

    final Future<AnalyticsOverview> future = useCase
        .call(filter: filter, topCategoriesLimit: 5)
        .first;

    categoryController.add(const <Category>[]);
    txController.add(<TransactionEntity>[
      TransactionEntity(
        id: 't1',
        accountId: 'acc-1',
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
        amountMinor: BigInt.from(25),
        amountScale: 2,
        date: DateTime(2024, 1, 12),
        type: TransactionType.expense.storageValue,
        createdAt: DateTime(2024, 1, 12),
        updatedAt: DateTime(2024, 1, 12),
      ),
    ]);

    final AnalyticsOverview overview = await future;

    expect(overview.totalIncome, _amount(150));
    expect(overview.totalExpense, _amount(25));
    expect(overview.netBalance, _amount(125));

    await txController.close();
    await categoryController.close();
  });

  test('analytics aggregates expenses by root category', () async {
    final StreamController<List<TransactionEntity>> txController =
        StreamController<List<TransactionEntity>>();
    final StreamController<List<Category>> categoryController =
        StreamController<List<Category>>();

    final Map<String, String?> roots = <String, String?>{
      'food': 'food',
      'coffee': 'food',
    };
    final WatchMonthlyAnalyticsUseCase useCase = WatchMonthlyAnalyticsUseCase(
      transactionRepository: _FakeTransactionRepository(
        txController,
        rootByCategoryId: roots,
      ),
      categoryRepository: _FakeCategoryRepository(categoryController),
    );

    final DateTime now = DateTime(2024, 1, 10);
    final AnalyticsFilter filter = AnalyticsFilter(
      start: DateTime(2024, 1, 1),
      end: DateTime(2024, 2, 1),
    );

    final Future<AnalyticsOverview> future = useCase
        .call(filter: filter, topCategoriesLimit: 5)
        .first;

    categoryController.add(<Category>[
      Category(
        id: 'food',
        name: 'Food',
        type: TransactionType.expense.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'coffee',
        name: 'Coffee',
        type: TransactionType.expense.storageValue,
        parentId: 'food',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    txController.add(<TransactionEntity>[
      TransactionEntity(
        id: 't1',
        accountId: 'acc-1',
        categoryId: 'coffee',
        amountMinor: BigInt.from(100),
        amountScale: 2,
        date: DateTime(2024, 1, 11),
        type: TransactionType.expense.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
      TransactionEntity(
        id: 't2',
        accountId: 'acc-1',
        categoryId: 'food',
        amountMinor: BigInt.from(40),
        amountScale: 2,
        date: DateTime(2024, 1, 12),
        type: TransactionType.expense.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    final AnalyticsOverview overview = await future;

    expect(overview.totalExpense, _amount(140));
    expect(overview.topExpenseCategories, hasLength(1));
    final AnalyticsCategoryBreakdown root = overview.topExpenseCategories.first;
    expect(root.categoryId, 'food');
    expect(root.amount, _amount(140));
    expect(root.children, hasLength(2));
    expect(
      root.children.where((AnalyticsCategoryBreakdown item) {
        return item.categoryId == 'coffee' && item.amount == _amount(100);
      }).length,
      1,
    );
    expect(
      root.children.where((AnalyticsCategoryBreakdown item) {
        return item.categoryId == '_direct:food' && item.amount == _amount(40);
      }).length,
      1,
    );

    await txController.close();
    await categoryController.close();
  });
}

MoneyAmount _amount(int minor, {int scale = 2}) {
  return MoneyAmount(minor: BigInt.from(minor), scale: scale);
}
