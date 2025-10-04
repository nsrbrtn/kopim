import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

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
