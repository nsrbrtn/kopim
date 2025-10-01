import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
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
double homeTotalBalance(Ref ref) {
  final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(homeAccountsProvider);

  return accountsAsync.maybeWhen(
    data: (List<AccountEntity> accounts) =>
        accounts.fold<double>(0, (double sum, AccountEntity account) => sum + account.balance),
    orElse: () => 0,
  );
}
