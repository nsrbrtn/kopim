import 'dart:async';
import 'dart:math' as math;

import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/services/category_hierarchy.dart';
import 'package:kopim/core/money/money_utils.dart';
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
      final MoneyAmount zero = MoneyAmount(minor: BigInt.zero, scale: 2);
      return AnalyticsOverview(
        totalIncome: zero,
        totalExpense: zero,
        netBalance: zero,
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

    final MoneyAccumulator totalIncome = MoneyAccumulator();
    final MoneyAccumulator totalExpense = MoneyAccumulator();
    final Map<String?, MoneyAccumulator> rawExpenseByCategory =
        <String?, MoneyAccumulator>{};
    final Map<String?, MoneyAccumulator> rawIncomeByCategory =
        <String?, MoneyAccumulator>{};

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

      final MoneyAmount amount = _resolveTransactionAmount(transaction);
      if (transaction.type == TransactionType.income.storageValue) {
        totalIncome.add(amount);
        if (categoryId == null || activeCategoryIds.contains(categoryId)) {
          rawIncomeByCategory
              .putIfAbsent(categoryId, MoneyAccumulator.new)
              .add(amount);
        }
      } else if (transaction.type == TransactionType.expense.storageValue) {
        totalExpense.add(amount);
        if (categoryId == null || activeCategoryIds.contains(categoryId)) {
          rawExpenseByCategory
              .putIfAbsent(categoryId, MoneyAccumulator.new)
              .add(amount);
        }
      }
    }

    final Map<String, MoneyAccumulator> aggregatedExpenses =
        _aggregateByCategory(rawExpenseByCategory, hierarchy);
    final Map<String, MoneyAccumulator> aggregatedIncomes =
        _aggregateByCategory(rawIncomeByCategory, hierarchy);

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
      totalIncome: _toMoneyAmount(totalIncome),
      totalExpense: _toMoneyAmount(totalExpense),
      netBalance: _calculateNetBalance(totalIncome, totalExpense),
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

  Map<String, MoneyAccumulator> _aggregateByCategory(
    Map<String?, MoneyAccumulator> rawByCategory,
    CategoryHierarchy hierarchy,
  ) {
    final Map<String, MoneyAccumulator> raw = <String, MoneyAccumulator>{};
    rawByCategory.forEach((String? id, MoneyAccumulator amount) {
      if (id != null && !amount.isZero) {
        raw[id] = amount;
      }
    });

    final Map<String, MoneyAccumulator> aggregated =
        <String, MoneyAccumulator>{};
    final Set<String> visiting = <String>{};

    MoneyAccumulator resolve(String id) {
      final MoneyAccumulator? cached = aggregated[id];
      if (cached != null) {
        return cached;
      }
      if (!visiting.add(id)) {
        return raw[id] ?? MoneyAccumulator();
      }
      final MoneyAccumulator sum = MoneyAccumulator();
      final MoneyAccumulator? direct = raw[id];
      if (direct != null) {
        sum.add(MoneyAmount(minor: direct.minor, scale: direct.scale));
      }
      for (final String childId in hierarchy.childrenOf(id)) {
        final MoneyAccumulator child = resolve(childId);
        sum.add(MoneyAmount(minor: child.minor, scale: child.scale));
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
    required Map<String?, MoneyAccumulator> rawByCategory,
    required Map<String, MoneyAccumulator> aggregatedByCategory,
    required Iterable<String> rootIds,
  }) {
    final List<AnalyticsCategoryBreakdown> result =
        <AnalyticsCategoryBreakdown>[];

    for (final String rootId in rootIds) {
      final MoneyAmount amount = _toMoneyAmount(aggregatedByCategory[rootId]);
      if (amount.minor <= BigInt.zero) {
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

    final MoneyAmount uncategorizedAmount = _toMoneyAmount(rawByCategory[null]);
    if (uncategorizedAmount.minor > BigInt.zero) {
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
    required Map<String?, MoneyAccumulator> rawByCategory,
    required Map<String, MoneyAccumulator> aggregatedByCategory,
  }) {
    final MoneyAmount totalAmount = _toMoneyAmount(
      aggregatedByCategory[categoryId],
    );
    final List<AnalyticsCategoryBreakdown> children =
        <AnalyticsCategoryBreakdown>[];

    final List<String> childIds = hierarchy.childrenOf(categoryId);
    final MoneyAmount directAmount = _toMoneyAmount(rawByCategory[categoryId]);
    if (childIds.isNotEmpty && directAmount.minor > BigInt.zero) {
      children.add(
        AnalyticsCategoryBreakdown(
          categoryId: '$analyticsDirectCategoryKeyPrefix$categoryId',
          amount: directAmount,
        ),
      );
    }

    for (final String childId in childIds) {
      final MoneyAmount childAmount = _toMoneyAmount(
        aggregatedByCategory[childId],
      );
      if (childAmount.minor <= BigInt.zero) {
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
            return b.amount.toDouble().compareTo(a.amount.toDouble());
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
      final MoneyAccumulator remainderAmount = MoneyAccumulator();
      for (final AnalyticsCategoryBreakdown breakdown in remainder) {
        remainderAmount.add(breakdown.amount);
      }
      top.add(
        AnalyticsCategoryBreakdown(
          categoryId: _othersCategoryKey,
          amount: _toMoneyAmount(remainderAmount),
          children: remainder,
        ),
      );
    }
    return top;
  }

  MoneyAmount _resolveTransactionAmount(TransactionEntity transaction) {
    return transaction.amountValue.abs();
  }

  MoneyAmount _toMoneyAmount(MoneyAccumulator? accumulator) {
    if (accumulator == null) {
      return MoneyAmount(minor: BigInt.zero, scale: 2);
    }
    return MoneyAmount(minor: accumulator.minor, scale: accumulator.scale);
  }

  MoneyAmount _calculateNetBalance(
    MoneyAccumulator income,
    MoneyAccumulator expense,
  ) {
    final MoneyAmount incomeAmount = _toMoneyAmount(income);
    final MoneyAmount expenseAmount = _toMoneyAmount(expense);
    final int targetScale = math.max(incomeAmount.scale, expenseAmount.scale);
    final MoneyAmount normalizedIncome = rescaleMoneyAmount(
      incomeAmount,
      targetScale,
    );
    final MoneyAmount normalizedExpense = rescaleMoneyAmount(
      expenseAmount,
      targetScale,
    );
    return MoneyAmount(
      minor: normalizedIncome.minor - normalizedExpense.minor,
      scale: targetScale,
    );
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
