import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_recent_transactions_use_case.dart';

part 'home_providers.g.dart';

const int kDefaultRecentTransactionsLimit = 5;

@riverpod
Stream<List<AccountEntity>> homeAccounts(HomeAccountsRef ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
}

@riverpod
Stream<List<TransactionEntity>> homeRecentTransactions(
  HomeRecentTransactionsRef ref, {
  int limit = kDefaultRecentTransactionsLimit,
}) {
  return ref.watch(watchRecentTransactionsUseCaseProvider).call(limit: limit);
}
