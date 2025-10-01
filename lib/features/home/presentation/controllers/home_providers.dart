import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

const int kDefaultRecentTransactionsLimit = 5;

@riverpod
Stream<List<AccountEntity>> homeAccounts(Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
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
double homeTotalBalance(Ref ref) {
  final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
    homeAccountsProvider,
  );

  return accountsAsync.maybeWhen(
    data: (List<AccountEntity> accounts) => accounts.fold<double>(
      0,
      (double sum, AccountEntity account) => sum + account.balance,
    ),
    orElse: () => 0,
  );
}

@riverpod
AsyncValue<Map<String, HomeAccountMonthlySummary>> homeAccountMonthlySummaries(
  Ref ref,
) {
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    homeRecentTransactionsProvider(limit: 0),
  );

  return transactionsAsync.whenData(
    (List<TransactionEntity> transactions) =>
        computeCurrentMonthSummaries(transactions: transactions),
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
