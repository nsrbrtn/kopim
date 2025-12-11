import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/usecases/watch_recent_transactions_use_case.dart';

/// Returns a limited stream of the most recent transactions for the home feed.
class WatchRecentTransactionsUseCaseImpl
    implements WatchRecentTransactionsUseCase {
  WatchRecentTransactionsUseCaseImpl({
    required TransactionRepository repository,
  }) : _repository = repository;

  final TransactionRepository _repository;

  @override
  Stream<List<TransactionEntity>> call({int limit = 50}) {
    final int? normalizedLimit = limit > 0 ? limit : null;
    return _repository
        .watchRecentTransactions(limit: normalizedLimit)
        .map(List<TransactionEntity>.unmodifiable);
  }
}
