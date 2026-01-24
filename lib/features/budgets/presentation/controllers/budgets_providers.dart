import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

part 'budgets_providers.g.dart';

@riverpod
Stream<List<Budget>> budgetsStream(Ref ref) {
  return ref.watch(watchBudgetsUseCaseProvider).call();
}

@riverpod
Stream<List<TransactionEntity>> budgetTransactionsStream(Ref ref) {
  return ref.watch(transactionRepositoryProvider).watchTransactions();
}

@riverpod
Stream<List<AccountEntity>> budgetAccountsStream(Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
}

@riverpod
Stream<List<Category>> budgetCategoriesStream(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}

@riverpod
Stream<Map<BudgetPeriodKey, List<BudgetExpenseTotals>>> budgetExpenseTotals(
  Ref ref,
) {
  final AsyncValue<List<Budget>> budgetsAsync = ref.watch(
    budgetsStreamProvider,
  );
  final List<Budget> budgets = budgetsAsync.value ?? const <Budget>[];
  if (budgets.isEmpty) {
    return Stream<Map<BudgetPeriodKey, List<BudgetExpenseTotals>>>.value(
      const <BudgetPeriodKey, List<BudgetExpenseTotals>>{},
    );
  }

  final DateTime now = DateTime.now();
  const BudgetSchedule schedule = BudgetSchedule();
  final TransactionRepository repository = ref.watch(
    transactionRepositoryProvider,
  );
  final List<_BudgetWindow> windows = _buildBudgetWindows(
    budgets: budgets,
    schedule: schedule,
    reference: now,
  );

  final List<Stream<_BudgetWindowTotals>> streams = windows
      .map(
        (_BudgetWindow window) => repository
            .watchBudgetExpenseTotals(
              start: window.key.start,
              end: window.key.end,
              accountIds: window.accountIds,
            )
            .map(
              (List<BudgetExpenseTotals> totals) =>
                  _BudgetWindowTotals(window.key, totals),
            ),
      )
      .toList(growable: false);

  return _combineLatestList(streams).map((List<_BudgetWindowTotals> totals) {
    final Map<BudgetPeriodKey, List<BudgetExpenseTotals>> byWindow =
        <BudgetPeriodKey, List<BudgetExpenseTotals>>{};
    for (final _BudgetWindowTotals entry in totals) {
      byWindow[entry.key] = entry.totals;
    }
    return byWindow;
  });
}

@riverpod
AsyncValue<List<BudgetProgress>> budgetsWithProgress(Ref ref) {
  final AsyncValue<List<Budget>> budgetsAsync = ref.watch(
    budgetsStreamProvider,
  );
  final AsyncValue<Map<BudgetPeriodKey, List<BudgetExpenseTotals>>>
  totalsAsync = ref.watch(budgetExpenseTotalsProvider);

  if (budgetsAsync.isLoading || totalsAsync.isLoading) {
    return const AsyncValue<List<BudgetProgress>>.loading();
  }

  final Object? error = budgetsAsync.error ?? totalsAsync.error;
  if (error != null) {
    return AsyncValue<List<BudgetProgress>>.error(
      error,
      budgetsAsync.stackTrace ?? totalsAsync.stackTrace ?? StackTrace.empty,
    );
  }

  final List<Budget> budgets = budgetsAsync.value ?? const <Budget>[];
  final ComputeBudgetProgressUseCase compute = ref.watch(
    computeBudgetProgressUseCaseProvider,
  );
  final DateTime now = DateTime.now();
  const BudgetSchedule schedule = BudgetSchedule();
  final Map<BudgetPeriodKey, List<BudgetExpenseTotals>> totalsByWindow =
      totalsAsync.value ?? const <BudgetPeriodKey, List<BudgetExpenseTotals>>{};

  final List<BudgetProgress> items = budgets
      .map((Budget budget) {
        final ({DateTime start, DateTime end}) period = schedule.periodFor(
          budget: budget,
          reference: now,
        );
        final BudgetPeriodKey key = BudgetPeriodKey(period.start, period.end);
        final List<BudgetExpenseTotals> totals =
            totalsByWindow[key] ?? const <BudgetExpenseTotals>[];
        final MoneyAmount spent = _sumBudgetExpenses(
          budget: budget,
          totals: totals,
        );
        return compute.buildFromSpent(
          budget: budget,
          spent: spent,
          reference: now,
        );
      })
      .sorted(
        (BudgetProgress a, BudgetProgress b) =>
            b.budget.updatedAt.compareTo(a.budget.updatedAt),
      )
      .toList(growable: false);

  return AsyncValue<List<BudgetProgress>>.data(items);
}

@riverpod
AsyncValue<List<BudgetCategorySpend>> budgetCategorySpend(Ref ref) {
  final AsyncValue<List<Budget>> budgetsAsync = ref.watch(
    budgetsStreamProvider,
  );
  final AsyncValue<Map<BudgetPeriodKey, List<BudgetExpenseTotals>>>
  totalsAsync = ref.watch(budgetExpenseTotalsProvider);
  final AsyncValue<List<Category>> categoriesAsync = ref.watch(
    budgetCategoriesStreamProvider,
  );

  if (budgetsAsync.isLoading ||
      totalsAsync.isLoading ||
      categoriesAsync.isLoading) {
    return const AsyncValue<List<BudgetCategorySpend>>.loading();
  }

  final Object? error =
      budgetsAsync.error ?? totalsAsync.error ?? categoriesAsync.error;
  if (error != null) {
    return AsyncValue<List<BudgetCategorySpend>>.error(
      error,
      budgetsAsync.stackTrace ??
          totalsAsync.stackTrace ??
          categoriesAsync.stackTrace ??
          StackTrace.empty,
    );
  }

  final List<Budget> budgets = budgetsAsync.value ?? const <Budget>[];
  final List<Category> categories = categoriesAsync.value ?? const <Category>[];
  final Map<BudgetPeriodKey, List<BudgetExpenseTotals>> totalsByWindow =
      totalsAsync.value ?? const <BudgetPeriodKey, List<BudgetExpenseTotals>>{};
  const BudgetSchedule schedule = BudgetSchedule();
  final DateTime now = DateTime.now();

  if (budgets.isEmpty || totalsByWindow.isEmpty) {
    return const AsyncValue<List<BudgetCategorySpend>>.data(
      <BudgetCategorySpend>[],
    );
  }

  final Map<String, MoneyAccumulator> aggregateSpent =
      <String, MoneyAccumulator>{};
  final Map<String, double> aggregateLimit = <String, double>{};

  for (final Budget budget in budgets) {
    if (budget.scope == BudgetScope.byAccount && budget.accounts.isEmpty) {
      continue;
    }

    if (budget.scope == BudgetScope.byCategory &&
        budget.categories.isEmpty &&
        budget.categoryAllocations.isEmpty) {
      continue;
    }

    final ({DateTime start, DateTime end}) period = schedule.periodFor(
      budget: budget,
      reference: now,
    );
    final BudgetPeriodKey key = BudgetPeriodKey(period.start, period.end);
    final List<BudgetExpenseTotals> totals =
        totalsByWindow[key] ?? const <BudgetExpenseTotals>[];
    if (totals.isEmpty) {
      continue;
    }

    final Set<String> scopedCategoryIds = <String>{};
    if (budget.categoryAllocations.isNotEmpty) {
      scopedCategoryIds.addAll(
        budget.categoryAllocations.map(
          (BudgetCategoryAllocation allocation) => allocation.categoryId,
        ),
      );
    } else if (budget.scope == BudgetScope.byCategory &&
        budget.categories.isNotEmpty) {
      scopedCategoryIds.addAll(budget.categories);
    }

    final Map<String, MoneyAccumulator> spentByCategory =
        <String, MoneyAccumulator>{};
    for (final BudgetExpenseTotals total in totals) {
      if (budget.scope == BudgetScope.byAccount &&
          !budget.accounts.contains(total.accountId)) {
        continue;
      }
      final String? categoryId = total.categoryId;
      if (categoryId == null) {
        continue;
      }
      if (scopedCategoryIds.isNotEmpty &&
          !scopedCategoryIds.contains(categoryId)) {
        continue;
      }
      spentByCategory
          .putIfAbsent(categoryId, MoneyAccumulator.new)
          .add(total.expense);
    }

    if (spentByCategory.isEmpty) {
      continue;
    }

    for (final MapEntry<String, MoneyAccumulator> entry
        in spentByCategory.entries) {
      final MoneyAccumulator accumulator = aggregateSpent.putIfAbsent(
        entry.key,
        MoneyAccumulator.new,
      );
      accumulator.add(
        MoneyAmount(minor: entry.value.minor, scale: entry.value.scale),
      );
      final double? limit = resolveBudgetCategoryLimit(budget, entry.key);
      if (limit != null) {
        aggregateLimit[entry.key] = (aggregateLimit[entry.key] ?? 0) + limit;
      }
    }
  }

  final List<BudgetCategorySpend> items = <BudgetCategorySpend>[];
  for (final MapEntry<String, MoneyAccumulator> entry
      in aggregateSpent.entries) {
    final Category? category = categories.firstWhereOrNull(
      (Category item) => item.id == entry.key,
    );
    if (category == null) {
      continue;
    }
    items.add(
      BudgetCategorySpend(
        category: category,
        spent: entry.value.toDouble(),
        limit: aggregateLimit[entry.key],
      ),
    );
  }

  items.sort(
    (BudgetCategorySpend a, BudgetCategorySpend b) =>
        b.spent.compareTo(a.spent),
  );

  return AsyncValue<List<BudgetCategorySpend>>.data(items);
}

@riverpod
AsyncValue<BudgetProgress> budgetProgressById(Ref ref, String budgetId) {
  final AsyncValue<List<BudgetProgress>> listAsync = ref.watch(
    budgetsWithProgressProvider,
  );
  return listAsync.whenData(
    (List<BudgetProgress> items) => items.firstWhere(
      (BudgetProgress progress) => progress.budget.id == budgetId,
      orElse: () => throw StateError('Budget $budgetId not found'),
    ),
  );
}

@riverpod
AsyncValue<List<TransactionEntity>> budgetTransactionsById(
  Ref ref,
  String budgetId,
) {
  final AsyncValue<List<Budget>> budgetsAsync = ref.watch(
    budgetsStreamProvider,
  );
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    budgetTransactionsStreamProvider,
  );
  if (budgetsAsync.isLoading || transactionsAsync.isLoading) {
    return const AsyncValue<List<TransactionEntity>>.loading();
  }
  final Object? error = budgetsAsync.error ?? transactionsAsync.error;
  if (error != null) {
    return AsyncValue<List<TransactionEntity>>.error(
      error,
      budgetsAsync.stackTrace ??
          transactionsAsync.stackTrace ??
          StackTrace.empty,
    );
  }
  final Budget? budget = budgetsAsync.value?.firstWhereOrNull(
    (Budget item) => item.id == budgetId,
  );
  if (budget == null) {
    return const AsyncValue<List<TransactionEntity>>.data(
      <TransactionEntity>[],
    );
  }
  final ComputeBudgetProgressUseCase compute = ref.watch(
    computeBudgetProgressUseCaseProvider,
  );
  final List<TransactionEntity> filtered = compute.filterTransactions(
    budget: budget,
    transactions: transactionsAsync.value ?? const <TransactionEntity>[],
  );
  return AsyncValue<List<TransactionEntity>>.data(filtered);
}

@riverpod
Future<List<BudgetInstance>> budgetInstancesByBudget(
  Ref ref,
  String budgetId,
) async {
  final BudgetRepository repository = ref.watch(budgetRepositoryProvider);
  return repository.loadInstances(budgetId);
}

double? resolveBudgetCategoryLimit(Budget budget, String categoryId) {
  final Iterable<BudgetCategoryAllocation> allocations = budget
      .categoryAllocations
      .where(
        (BudgetCategoryAllocation allocation) =>
            allocation.categoryId == categoryId,
      );
  if (allocations.isNotEmpty) {
    return allocations.fold<double>(
      0,
      (double previous, BudgetCategoryAllocation allocation) =>
          previous + allocation.limitValue.toDouble(),
    );
  }
  if (budget.scope == BudgetScope.byCategory &&
      budget.categories.length == 1 &&
      budget.categories.first == categoryId) {
    return budget.amountValue.toDouble();
  }
  return null;
}

class BudgetPeriodKey {
  const BudgetPeriodKey(this.start, this.end);

  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetPeriodKey && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

class _BudgetWindow {
  _BudgetWindow({required this.key, required this.accountIds});

  final BudgetPeriodKey key;
  final List<String> accountIds;
}

class _BudgetWindowTotals {
  const _BudgetWindowTotals(this.key, this.totals);

  final BudgetPeriodKey key;
  final List<BudgetExpenseTotals> totals;
}

List<_BudgetWindow> _buildBudgetWindows({
  required List<Budget> budgets,
  required BudgetSchedule schedule,
  required DateTime reference,
}) {
  final Map<BudgetPeriodKey, _BudgetWindowBuilder> grouped =
      <BudgetPeriodKey, _BudgetWindowBuilder>{};
  for (final Budget budget in budgets) {
    final ({DateTime start, DateTime end}) period = schedule.periodFor(
      budget: budget,
      reference: reference,
    );
    final BudgetPeriodKey key = BudgetPeriodKey(period.start, period.end);
    final _BudgetWindowBuilder builder = grouped.putIfAbsent(
      key,
      () => _BudgetWindowBuilder(key),
    );
    builder.addBudget(budget);
  }

  return grouped.values
      .map((_BudgetWindowBuilder builder) {
        return _BudgetWindow(key: builder.key, accountIds: builder.accountIds);
      })
      .toList(growable: false);
}

class _BudgetWindowBuilder {
  _BudgetWindowBuilder(this.key);

  final BudgetPeriodKey key;
  final Set<String> _accountIds = <String>{};
  bool _requiresAllAccounts = false;

  void addBudget(Budget budget) {
    if (budget.scope != BudgetScope.byAccount || budget.accounts.isEmpty) {
      _requiresAllAccounts = true;
      return;
    }
    if (!_requiresAllAccounts) {
      _accountIds.addAll(budget.accounts);
    }
  }

  List<String> get accountIds =>
      _requiresAllAccounts ? const <String>[] : _accountIds.toList();
}

MoneyAmount _sumBudgetExpenses({
  required Budget budget,
  required List<BudgetExpenseTotals> totals,
}) {
  if (budget.scope == BudgetScope.byAccount && budget.accounts.isEmpty) {
    return MoneyAmount(minor: BigInt.zero, scale: 2);
  }
  if (budget.scope == BudgetScope.byCategory && budget.categories.isEmpty) {
    return MoneyAmount(minor: BigInt.zero, scale: 2);
  }
  final MoneyAccumulator accumulator = MoneyAccumulator();
  for (final BudgetExpenseTotals total in totals) {
    if (budget.scope == BudgetScope.byAccount &&
        !budget.accounts.contains(total.accountId)) {
      continue;
    }
    if (budget.scope == BudgetScope.byCategory) {
      final String? categoryId = total.categoryId;
      if (categoryId == null || !budget.categories.contains(categoryId)) {
        continue;
      }
    }
    accumulator.add(total.expense);
  }
  return MoneyAmount(minor: accumulator.minor, scale: accumulator.scale);
}

Stream<List<T>> _combineLatestList<T>(List<Stream<T>> streams) {
  if (streams.isEmpty) {
    return Stream<List<T>>.value(<T>[]);
  }

  late final StreamController<List<T>> controller;
  final List<T?> latest = List<T?>.filled(streams.length, null);
  final List<bool> hasValue = List<bool>.filled(streams.length, false);
  final List<StreamSubscription<T>> subscriptions = <StreamSubscription<T>>[];

  void emitIfReady() {
    if (hasValue.every((bool value) => value)) {
      controller.add(List<T>.unmodifiable(latest.cast<T>()));
    }
  }

  controller = StreamController<List<T>>(
    onListen: () {
      for (int index = 0; index < streams.length; index += 1) {
        final StreamSubscription<T> subscription = streams[index].listen((
          T value,
        ) {
          latest[index] = value;
          hasValue[index] = true;
          emitIfReady();
        }, onError: controller.addError);
        subscriptions.add(subscription);
      }
    },
    onCancel: () async {
      for (final StreamSubscription<T> sub in subscriptions) {
        await sub.cancel();
      }
    },
  );

  return controller.stream;
}
