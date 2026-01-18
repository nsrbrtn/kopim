import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/home/domain/models/home_overview_summary.dart';
import 'package:kopim/features/home/domain/use_cases/group_transactions_by_day_use_case.dart';
import 'package:kopim/features/home/presentation/controllers/home_transactions_filter_controller.dart';
import 'package:kopim/features/overview/domain/entities/overview_preferences.dart';
import 'package:kopim/features/overview/presentation/controllers/overview_preferences_controller.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

const int kDefaultRecentTransactionsLimit = 30;

@riverpod
Stream<List<AccountEntity>> homeAccounts(Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call().map(_sortAccounts);
}

@riverpod
Stream<List<TransactionEntity>> homeRecentTransactions(
  Ref ref, {
  int limit = kDefaultRecentTransactionsLimit,
}) {
  return ref.watch(watchRecentTransactionsUseCaseProvider).call(limit: limit);
}

@riverpod
Stream<List<Category>> homeCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}

@riverpod
TransactionEntity? homeTransactionById(Ref ref, String id) {
  return ref
      .watch(homeRecentTransactionsProvider())
      .maybeWhen(
        data: (List<TransactionEntity> transactions) =>
            _findTransactionById(transactions, id),
        orElse: () => null,
      );
}

@riverpod
AccountEntity? homeAccountById(Ref ref, String id) {
  return ref
      .watch(homeAccountsProvider)
      .maybeWhen(
        data: (List<AccountEntity> accounts) => _findAccountById(accounts, id),
        orElse: () => null,
      );
}

@riverpod
Category? homeCategoryById(Ref ref, String id) {
  return ref
      .watch(homeCategoriesProvider)
      .maybeWhen(
        data: (List<Category> categories) => _findCategoryById(categories, id),
        orElse: () => null,
      );
}

@riverpod
Stream<List<SavingGoal>> homeSavingGoals(Ref ref) {
  return ref
      .watch(watchSavingGoalsUseCaseProvider)
      .call(includeArchived: false);
}

@riverpod
AsyncValue<List<GoalProgress>> homeSavingGoalProgress(Ref ref) {
  return ref
      .watch(homeSavingGoalsProvider)
      .whenData(
        (List<SavingGoal> goals) => goals
            .where((SavingGoal goal) => !goal.isArchived)
            .map(GoalProgress.fromGoal)
            .toList(growable: false),
      );
}

@riverpod
AsyncValue<List<DaySection>> homeGroupedTransactions(Ref ref) {
  final GroupTransactionsByDayUseCase useCase = ref.watch(
    groupTransactionsByDayUseCaseProvider,
  );
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    homeRecentTransactionsProvider(),
  );
  final HomeTransactionsFilter filter = ref.watch(
    homeTransactionsFilterControllerProvider,
  );

  return transactionsAsync.whenData((List<TransactionEntity> transactions) {
    final List<TransactionEntity> filtered = _filterTransactionsByType(
      transactions,
      filter,
    );
    return useCase(transactions: filtered);
  });
}

@riverpod
Stream<Map<String, HomeAccountMonthlySummary>> homeAccountMonthlySummaries(
  Ref ref,
) {
  final Stream<List<AccountMonthlyTotals>> totalsStream = ref
      .watch(watchAccountMonthlyTotalsUseCaseProvider)
      .call();
  return totalsStream.map((List<AccountMonthlyTotals> totals) {
    if (totals.isEmpty) {
      return const <String, HomeAccountMonthlySummary>{};
    }
    final Map<String, HomeAccountMonthlySummary> mapped =
        <String, HomeAccountMonthlySummary>{};
    for (final AccountMonthlyTotals item in totals) {
      mapped[item.accountId] = HomeAccountMonthlySummary(
        income: item.income,
        expense: item.expense,
      );
    }
    return Map<String, HomeAccountMonthlySummary>.unmodifiable(mapped);
  });
}

@riverpod
Stream<HomeOverviewSummary> homeOverviewSummary(Ref ref) {
  final OverviewPreferences preferences = ref
      .watch(overviewPreferencesControllerProvider)
      .maybeWhen(
        data: (OverviewPreferences value) => value,
        orElse: () {
          return const OverviewPreferences();
        },
      );
  return ref
      .watch(watchHomeOverviewSummaryUseCaseProvider)
      .call(
        accountIdsFilter: preferences.accountIdSet,
        categoryIdsFilter: preferences.categoryIdSet,
      );
}

@visibleForTesting
Map<String, HomeAccountMonthlySummary> computeCurrentMonthSummaries({
  required List<TransactionEntity> transactions,
  DateTime? now,
}) {
  if (transactions.isEmpty) {
    return const <String, HomeAccountMonthlySummary>{};
  }

  final DateTime reference = now ?? DateTime.now();
  final DateTime monthStart = DateTime(reference.year, reference.month);
  final DateTime nextMonth = DateTime(reference.year, reference.month + 1);
  final Map<String, ({double income, double expense})> accumulator =
      <String, ({double income, double expense})>{};

  for (final TransactionEntity transaction in transactions) {
    if (transaction.date.isBefore(monthStart) ||
        !transaction.date.isBefore(nextMonth)) {
      continue;
    }

    final ({double income, double expense}) current =
        accumulator[transaction.accountId] ?? (income: 0, expense: 0);
    if (transaction.type == TransactionType.income.storageValue) {
      accumulator[transaction.accountId] = (
        income: current.income + transaction.amount.abs(),
        expense: current.expense,
      );
    } else if (transaction.type == TransactionType.expense.storageValue) {
      accumulator[transaction.accountId] = (
        income: current.income,
        expense: current.expense + transaction.amount.abs(),
      );
    }
  }

  return accumulator.map(
    (String accountId, ({double income, double expense}) value) =>
        MapEntry<String, HomeAccountMonthlySummary>(
          accountId,
          HomeAccountMonthlySummary(
            income: value.income,
            expense: value.expense,
          ),
        ),
  );
}

TransactionEntity? _findTransactionById(
  List<TransactionEntity> transactions,
  String id,
) {
  for (final TransactionEntity transaction in transactions) {
    if (transaction.id == id) {
      return transaction;
    }
  }
  return null;
}

List<TransactionEntity> _filterTransactionsByType(
  List<TransactionEntity> transactions,
  HomeTransactionsFilter filter,
) {
  if (filter == HomeTransactionsFilter.all) {
    return transactions;
  }
  final String targetType = filter == HomeTransactionsFilter.income
      ? TransactionType.income.storageValue
      : TransactionType.expense.storageValue;
  return transactions
      .where((TransactionEntity transaction) => transaction.type == targetType)
      .toList(growable: false);
}

AccountEntity? _findAccountById(List<AccountEntity> accounts, String id) {
  for (final AccountEntity account in accounts) {
    if (account.id == id) {
      return account;
    }
  }
  return null;
}

Category? _findCategoryById(List<Category> categories, String id) {
  for (final Category category in categories) {
    if (category.id == id) {
      return category;
    }
  }
  return null;
}

List<AccountEntity> _sortAccounts(List<AccountEntity> accounts) {
  if (accounts.length < 2) {
    return accounts;
  }
  final List<_IndexedAccount> indexed = <_IndexedAccount>[];
  for (int i = 0; i < accounts.length; i += 1) {
    indexed.add(_IndexedAccount(accounts[i], i));
  }
  indexed.sort((_IndexedAccount a, _IndexedAccount b) {
    if (a.account.isPrimary != b.account.isPrimary) {
      return a.account.isPrimary ? -1 : 1;
    }
    return a.index.compareTo(b.index);
  });
  return indexed
      .map((_IndexedAccount item) => item.account)
      .toList(growable: false);
}

class _IndexedAccount {
  const _IndexedAccount(this.account, this.index);

  final AccountEntity account;
  final int index;
}
