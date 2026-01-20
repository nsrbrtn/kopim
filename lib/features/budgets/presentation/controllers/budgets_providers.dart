import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

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
AsyncValue<List<BudgetProgress>> budgetsWithProgress(Ref ref) {
  final AsyncValue<List<Budget>> budgetsAsync = ref.watch(
    budgetsStreamProvider,
  );
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    budgetTransactionsStreamProvider,
  );

  if (budgetsAsync.isLoading || transactionsAsync.isLoading) {
    return const AsyncValue<List<BudgetProgress>>.loading();
  }

  final Object? error = budgetsAsync.error ?? transactionsAsync.error;
  if (error != null) {
    return AsyncValue<List<BudgetProgress>>.error(
      error,
      budgetsAsync.stackTrace ??
          transactionsAsync.stackTrace ??
          StackTrace.empty,
    );
  }

  final List<Budget> budgets = budgetsAsync.value ?? const <Budget>[];
  final List<TransactionEntity> transactions =
      transactionsAsync.value ?? const <TransactionEntity>[];
  final ComputeBudgetProgressUseCase compute = ref.watch(
    computeBudgetProgressUseCaseProvider,
  );

  final List<BudgetProgress> items = budgets
      .map(
        (Budget budget) => compute(budget: budget, transactions: transactions),
      )
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
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    budgetTransactionsStreamProvider,
  );
  final AsyncValue<List<Category>> categoriesAsync = ref.watch(
    budgetCategoriesStreamProvider,
  );

  if (budgetsAsync.isLoading ||
      transactionsAsync.isLoading ||
      categoriesAsync.isLoading) {
    return const AsyncValue<List<BudgetCategorySpend>>.loading();
  }

  final Object? error =
      budgetsAsync.error ?? transactionsAsync.error ?? categoriesAsync.error;
  if (error != null) {
    return AsyncValue<List<BudgetCategorySpend>>.error(
      error,
      budgetsAsync.stackTrace ??
          transactionsAsync.stackTrace ??
          categoriesAsync.stackTrace ??
          StackTrace.empty,
    );
  }

  final List<Budget> budgets = budgetsAsync.value ?? const <Budget>[];
  final List<TransactionEntity> transactions =
      transactionsAsync.value ?? const <TransactionEntity>[];
  final List<Category> categories = categoriesAsync.value ?? const <Category>[];

  if (budgets.isEmpty || transactions.isEmpty) {
    return const AsyncValue<List<BudgetCategorySpend>>.data(
      <BudgetCategorySpend>[],
    );
  }

  final ComputeBudgetProgressUseCase compute = ref.watch(
    computeBudgetProgressUseCaseProvider,
  );
  final Map<String, _CategoryAccumulator> aggregate =
      <String, _CategoryAccumulator>{};

  for (final Budget budget in budgets) {
    final List<TransactionEntity> scopedTransactions = compute
        .filterTransactions(budget: budget, transactions: transactions);
    if (scopedTransactions.isEmpty) {
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

    final Map<String, double> spentByCategory = <String, double>{};
    for (final TransactionEntity transaction in scopedTransactions) {
      if (transaction.type == TransactionType.income.storageValue) {
        continue;
      }
      final String? categoryId = transaction.categoryId;
      if (categoryId == null) {
        continue;
      }
      if (scopedCategoryIds.isNotEmpty &&
          !scopedCategoryIds.contains(categoryId)) {
        continue;
      }
    spentByCategory[categoryId] =
        (spentByCategory[categoryId] ?? 0) +
        transaction.amountValue.abs().toDouble();
    }

    if (spentByCategory.isEmpty) {
      continue;
    }

    for (final MapEntry<String, double> entry in spentByCategory.entries) {
      final _CategoryAccumulator accumulator = aggregate.putIfAbsent(
        entry.key,
        () => _CategoryAccumulator(),
      );
      accumulator.spent += entry.value;
      final double? limit = resolveBudgetCategoryLimit(budget, entry.key);
      if (limit != null) {
        accumulator.limit = (accumulator.limit ?? 0) + limit;
      }
    }
  }

  final List<BudgetCategorySpend> items = <BudgetCategorySpend>[];
  for (final MapEntry<String, _CategoryAccumulator> entry
      in aggregate.entries) {
    final Category? category = categories.firstWhereOrNull(
      (Category item) => item.id == entry.key,
    );
    if (category == null) {
      continue;
    }
    items.add(
      BudgetCategorySpend(
        category: category,
        spent: entry.value.spent,
        limit: entry.value.limit,
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
          previous + allocation.limit,
    );
  }
  if (budget.scope == BudgetScope.byCategory &&
      budget.categories.length == 1 &&
      budget.categories.first == categoryId) {
    return budget.amount;
  }
  return null;
}

class _CategoryAccumulator {
  double spent = 0;
  double? limit;
}
