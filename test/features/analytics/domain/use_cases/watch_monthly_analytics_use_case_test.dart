import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
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
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

void main() {
  group('WatchMonthlyAnalyticsUseCase', () {
    late FakeTransactionRepository repository;
    late FakeCategoryRepository categoryRepository;
    late WatchMonthlyAnalyticsUseCase useCase;

    setUp(() {
      repository = FakeTransactionRepository();
      categoryRepository = FakeCategoryRepository();
      useCase = WatchMonthlyAnalyticsUseCase(
        transactionRepository: repository,
        categoryRepository: categoryRepository,
      );
    });

    tearDown(() async {
      await repository.dispose();
      await categoryRepository.dispose();
    });

    test('returns zero overview when there are no transactions', () async {
      final Future<AnalyticsOverview> future = useCase.call().first;

      await categoryRepository.emit(<Category>[]);
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

      await categoryRepository.emit(<Category>[
        buildCategory(id: 'cat-ent'),
        buildCategory(id: 'cat-food'),
        buildCategory(id: 'cat-travel'),
      ]);
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

      await categoryRepository.emit(<Category>[
        buildCategory(id: 'cat-ent'),
        buildCategory(id: 'cat-food'),
      ]);
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

    test('aggregates parent categories with descendants', () async {
      final AnalyticsFilter filter = AnalyticsFilter(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 7, 1),
      );
      final Future<AnalyticsOverview> future = useCase
          .call(filter: filter, topCategoriesLimit: 10)
          .first;

      await categoryRepository.emit(<Category>[
        buildCategory(id: 'cat-food'),
        buildCategory(id: 'cat-veg', parentId: 'cat-food'),
        buildCategory(id: 'cat-fruit', parentId: 'cat-food'),
      ]);
      await repository.emit(<TransactionEntity>[
        buildTransaction(
          id: 't1',
          accountId: 'acc-1',
          amount: -100,
          date: DateTime(2024, 6, 10),
          categoryId: 'cat-food',
          type: TransactionType.expense,
        ),
        buildTransaction(
          id: 't2',
          accountId: 'acc-1',
          amount: -100,
          date: DateTime(2024, 6, 11),
          categoryId: 'cat-veg',
          type: TransactionType.expense,
        ),
        buildTransaction(
          id: 't3',
          accountId: 'acc-1',
          amount: -100,
          date: DateTime(2024, 6, 12),
          categoryId: 'cat-fruit',
          type: TransactionType.expense,
        ),
      ]);

      final AnalyticsOverview overview = await future;
      expect(overview.topExpenseCategories, hasLength(1));
      final AnalyticsCategoryBreakdown parent =
          overview.topExpenseCategories.first;
      expect(parent.categoryId, 'cat-food');
      expect(parent.amount, 300);
      expect(parent.children, hasLength(3));
      final AnalyticsCategoryBreakdown direct = parent.children.firstWhere(
        (AnalyticsCategoryBreakdown item) =>
            item.categoryId != null &&
            parseAnalyticsDirectCategoryParentId(item.categoryId!) ==
                'cat-food',
      );
      expect(direct.amount, 100);
      final AnalyticsCategoryBreakdown veg = parent.children.firstWhere(
        (AnalyticsCategoryBreakdown item) => item.categoryId == 'cat-veg',
      );
      final AnalyticsCategoryBreakdown fruit = parent.children.firstWhere(
        (AnalyticsCategoryBreakdown item) => item.categoryId == 'cat-fruit',
      );
      expect(veg.amount, 100);
      expect(fruit.amount, 100);
    });

    test(
      'category filter can exclude descendants when includeSubcategories is false',
      () async {
        final AnalyticsFilter filter = AnalyticsFilter(
          start: DateTime(2024, 6, 1),
          end: DateTime(2024, 7, 1),
          categoryId: 'cat-food',
          includeSubcategories: false,
        );
        final Future<AnalyticsOverview> future = useCase
            .call(filter: filter)
            .first;

        await categoryRepository.emit(<Category>[
          buildCategory(id: 'cat-food'),
          buildCategory(id: 'cat-veg', parentId: 'cat-food'),
        ]);
        await repository.emit(<TransactionEntity>[
          buildTransaction(
            id: 't1',
            accountId: 'acc-1',
            amount: -100,
            date: DateTime(2024, 6, 10),
            categoryId: 'cat-food',
            type: TransactionType.expense,
          ),
          buildTransaction(
            id: 't2',
            accountId: 'acc-1',
            amount: -50,
            date: DateTime(2024, 6, 11),
            categoryId: 'cat-veg',
            type: TransactionType.expense,
          ),
        ]);

        final AnalyticsOverview overview = await future;
        expect(overview.totalExpense, 100);
        expect(overview.topExpenseCategories, hasLength(1));
        expect(overview.topExpenseCategories.first.categoryId, 'cat-food');
        expect(overview.topExpenseCategories.first.amount, 100);
      },
    );
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

Category buildCategory({required String id, String? parentId}) {
  final DateTime now = DateTime(2024, 6, 1);
  return Category(
    id: id,
    name: id,
    type: 'expense',
    parentId: parentId,
    createdAt: now,
    updatedAt: now,
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

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    return const Stream<List<AccountMonthlyTotals>>.empty();
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

class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository()
    : _controller = StreamController<List<Category>>.broadcast();

  final StreamController<List<Category>> _controller;

  @override
  Stream<List<Category>> watchCategories() => _controller.stream;

  Future<void> emit(List<Category> categories) async {
    _controller.add(categories);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> dispose() async {
    await _controller.close();
  }

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
