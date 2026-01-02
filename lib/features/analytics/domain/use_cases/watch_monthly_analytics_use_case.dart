import 'dart:async';
import 'dart:math' as math;

import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/services/category_hierarchy.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

const String _othersCategoryKey = '_others';

class WatchMonthlyAnalyticsUseCase {
  WatchMonthlyAnalyticsUseCase({
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
  }) : _transactionRepository = transactionRepository,
       _categoryRepository = categoryRepository;

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  Stream<AnalyticsOverview> call({
    DateTime? reference,
    int topCategoriesLimit = 5,
    AnalyticsFilter? filter,
  }) {
    final AnalyticsFilter effectiveFilter =
        filter ?? AnalyticsFilter.monthly(reference: reference);
    return _combineLatest(
      _transactionRepository.watchTransactions(),
      _categoryRepository.watchCategories(),
      (List<TransactionEntity> transactions, List<Category> categories) =>
          _buildOverview(
            transactions: transactions,
            categories: categories,
            filter: effectiveFilter,
            topCategoriesLimit: topCategoriesLimit,
          ),
    );
  }

  AnalyticsOverview _buildOverview({
    required List<TransactionEntity> transactions,
    required List<Category> categories,
    required AnalyticsFilter filter,
    required int topCategoriesLimit,
  }) {
    if (transactions.isEmpty) {
      return const AnalyticsOverview(
        totalIncome: 0,
        totalExpense: 0,
        netBalance: 0,
        topExpenseCategories: <AnalyticsCategoryBreakdown>[],
        topIncomeCategories: <AnalyticsCategoryBreakdown>[],
      );
    }

    final CategoryHierarchy hierarchy = CategoryHierarchy(categories);
    final Set<String> activeCategoryIds = hierarchy.byId.keys.toSet();
    final DateTime start = filter.start;
    final DateTime end = filter.end;
    final Set<String> accountIds =
        filter.accountIds?.toSet() ?? const <String>{};

    final Set<String>? categoryFilterIds = _resolveCategoryFilterIds(
      filter,
      hierarchy,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String?, double> rawExpenseByCategory = <String?, double>{};
    final Map<String?, double> rawIncomeByCategory = <String?, double>{};

    for (final TransactionEntity transaction in transactions) {
      if (transaction.date.isBefore(start) || !transaction.date.isBefore(end)) {
        continue;
      }

      if (accountIds.isNotEmpty &&
          !accountIds.contains(transaction.accountId)) {
        continue;
      }

      if (filter.accountId != null &&
          transaction.accountId != filter.accountId) {
        continue;
      }

      final String? categoryId = transaction.categoryId;
      if (categoryFilterIds != null) {
        if (categoryId == null || !categoryFilterIds.contains(categoryId)) {
          continue;
        }
      }

      final double amount = transaction.amount.abs();
      if (transaction.type == TransactionType.income.storageValue) {
        totalIncome += amount;
        if (categoryId == null || activeCategoryIds.contains(categoryId)) {
          rawIncomeByCategory[categoryId] =
              (rawIncomeByCategory[categoryId] ?? 0) + amount;
        }
      } else if (transaction.type == TransactionType.expense.storageValue) {
        totalExpense += amount;
        if (categoryId == null || activeCategoryIds.contains(categoryId)) {
          rawExpenseByCategory[categoryId] =
              (rawExpenseByCategory[categoryId] ?? 0) + amount;
        }
      }
    }

    final Map<String, double> aggregatedExpenses = _aggregateByCategory(
      rawExpenseByCategory,
      hierarchy,
    );
    final Map<String, double> aggregatedIncomes = _aggregateByCategory(
      rawIncomeByCategory,
      hierarchy,
    );

    final List<AnalyticsCategoryBreakdown> expenseBreakdowns =
        _buildRootBreakdowns(
          hierarchy: hierarchy,
          rawByCategory: rawExpenseByCategory,
          aggregatedByCategory: aggregatedExpenses,
          rootIds: _resolveBreakdownRoots(filter, hierarchy),
        );
    final List<AnalyticsCategoryBreakdown> incomeBreakdowns =
        _buildRootBreakdowns(
          hierarchy: hierarchy,
          rawByCategory: rawIncomeByCategory,
          aggregatedByCategory: aggregatedIncomes,
          rootIds: _resolveBreakdownRoots(filter, hierarchy),
        );

    final List<AnalyticsCategoryBreakdown> topExpenses = _buildTopWithOthers(
      expenseBreakdowns,
      topCategoriesLimit,
    );
    final List<AnalyticsCategoryBreakdown> topIncomes = _buildTopWithOthers(
      incomeBreakdowns,
      topCategoriesLimit,
    );

    return AnalyticsOverview(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: totalIncome - totalExpense,
      topExpenseCategories: List<AnalyticsCategoryBreakdown>.unmodifiable(
        topExpenses,
      ),
      topIncomeCategories: List<AnalyticsCategoryBreakdown>.unmodifiable(
        topIncomes,
      ),
    );
  }

  List<String> _resolveBreakdownRoots(
    AnalyticsFilter filter,
    CategoryHierarchy hierarchy,
  ) {
    final String? categoryId = filter.categoryId;
    if (categoryId != null && hierarchy.contains(categoryId)) {
      return <String>[categoryId];
    }
    return hierarchy.rootIds;
  }

  Set<String>? _resolveCategoryFilterIds(
    AnalyticsFilter filter,
    CategoryHierarchy hierarchy,
  ) {
    final String? categoryId = filter.categoryId;
    if (categoryId == null) {
      return null;
    }
    if (!filter.includeSubcategories) {
      return <String>{categoryId};
    }
    final Set<String> ids = <String>{categoryId};
    ids.addAll(hierarchy.descendantsOf(categoryId));
    return ids;
  }

  Map<String, double> _aggregateByCategory(
    Map<String?, double> rawByCategory,
    CategoryHierarchy hierarchy,
  ) {
    final Map<String, double> raw = <String, double>{};
    rawByCategory.forEach((String? id, double amount) {
      if (id != null) {
        raw[id] = amount;
      }
    });

    final Map<String, double> aggregated = <String, double>{};
    final Set<String> visiting = <String>{};

    double resolve(String id) {
      final double? cached = aggregated[id];
      if (cached != null) {
        return cached;
      }
      if (!visiting.add(id)) {
        return raw[id] ?? 0;
      }
      double sum = raw[id] ?? 0;
      for (final String childId in hierarchy.childrenOf(id)) {
        sum += resolve(childId);
      }
      visiting.remove(id);
      aggregated[id] = sum;
      return sum;
    }

    for (final String id in hierarchy.byId.keys) {
      resolve(id);
    }
    return aggregated;
  }

  List<AnalyticsCategoryBreakdown> _buildRootBreakdowns({
    required CategoryHierarchy hierarchy,
    required Map<String?, double> rawByCategory,
    required Map<String, double> aggregatedByCategory,
    required Iterable<String> rootIds,
  }) {
    final List<AnalyticsCategoryBreakdown> result =
        <AnalyticsCategoryBreakdown>[];

    for (final String rootId in rootIds) {
      final double amount = aggregatedByCategory[rootId] ?? 0;
      if (amount <= 0) {
        continue;
      }
      result.add(
        _buildBreakdownNode(
          categoryId: rootId,
          hierarchy: hierarchy,
          rawByCategory: rawByCategory,
          aggregatedByCategory: aggregatedByCategory,
        ),
      );
    }

    final double uncategorizedAmount = rawByCategory[null] ?? 0;
    if (uncategorizedAmount > 0) {
      result.add(
        AnalyticsCategoryBreakdown(
          categoryId: null,
          amount: uncategorizedAmount,
        ),
      );
    }

    return result;
  }

  AnalyticsCategoryBreakdown _buildBreakdownNode({
    required String categoryId,
    required CategoryHierarchy hierarchy,
    required Map<String?, double> rawByCategory,
    required Map<String, double> aggregatedByCategory,
  }) {
    final double totalAmount = aggregatedByCategory[categoryId] ?? 0;
    final List<AnalyticsCategoryBreakdown> children =
        <AnalyticsCategoryBreakdown>[];

    final List<String> childIds = hierarchy.childrenOf(categoryId);
    final double directAmount = rawByCategory[categoryId] ?? 0;
    if (childIds.isNotEmpty && directAmount > 0) {
      children.add(
        AnalyticsCategoryBreakdown(
          categoryId: '$analyticsDirectCategoryKeyPrefix$categoryId',
          amount: directAmount,
        ),
      );
    }

    for (final String childId in childIds) {
      final double childAmount = aggregatedByCategory[childId] ?? 0;
      if (childAmount <= 0) {
        continue;
      }
      children.add(
        _buildBreakdownNode(
          categoryId: childId,
          hierarchy: hierarchy,
          rawByCategory: rawByCategory,
          aggregatedByCategory: aggregatedByCategory,
        ),
      );
    }

    return AnalyticsCategoryBreakdown(
      categoryId: categoryId,
      amount: totalAmount,
      children: children,
    );
  }

  List<AnalyticsCategoryBreakdown> _buildTopWithOthers(
    List<AnalyticsCategoryBreakdown> breakdowns,
    int topCategoriesLimit,
  ) {
    if (breakdowns.isEmpty) {
      return const <AnalyticsCategoryBreakdown>[];
    }
    final List<AnalyticsCategoryBreakdown> sorted =
        breakdowns.toList(growable: false)
          ..sort((AnalyticsCategoryBreakdown a, AnalyticsCategoryBreakdown b) {
            return b.amount.compareTo(a.amount);
          });

    final int limit = topCategoriesLimit <= 0
        ? sorted.length
        : math.min(topCategoriesLimit, sorted.length);

    final List<AnalyticsCategoryBreakdown> top = sorted
        .take(limit)
        .toList(growable: true);

    if (sorted.length > limit) {
      final List<AnalyticsCategoryBreakdown> remainder = sorted
          .skip(limit)
          .toList(growable: false);
      final double remainderAmount = remainder.fold<double>(
        0,
        (double previous, AnalyticsCategoryBreakdown breakdown) =>
            previous + breakdown.amount,
      );
      top.add(
        AnalyticsCategoryBreakdown(
          categoryId: _othersCategoryKey,
          amount: remainderAmount,
          children: remainder,
        ),
      );
    }
    return top;
  }

  Stream<T> _combineLatest<A, B, T>(
    Stream<A> first,
    Stream<B> second,
    T Function(A first, B second) combiner,
  ) {
    late final StreamController<T> controller;
    A? latestFirst;
    B? latestSecond;
    bool hasFirst = false;
    bool hasSecond = false;
    late StreamSubscription<A> firstSub;
    late StreamSubscription<B> secondSub;

    void emitIfReady() {
      if (hasFirst && hasSecond) {
        controller.add(combiner(latestFirst as A, latestSecond as B));
      }
    }

    controller = StreamController<T>(
      onListen: () {
        firstSub = first.listen((A value) {
          latestFirst = value;
          hasFirst = true;
          emitIfReady();
        }, onError: controller.addError);
        secondSub = second.listen((B value) {
          latestSecond = value;
          hasSecond = true;
          emitIfReady();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await firstSub.cancel();
        await secondSub.cancel();
      },
    );
    return controller.stream;
  }
}
