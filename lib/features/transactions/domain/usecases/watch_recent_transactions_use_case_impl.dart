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
    return _repository.watchTransactions().map(
      (List<TransactionEntity> transactions) {
        final List<TransactionEntity> sorted =
            List<TransactionEntity>.from(transactions)
              ..sort(
                (TransactionEntity a, TransactionEntity b) =>
                    b.date.compareTo(a.date),
              );
        if (sorted.length <= limit) {
          return List<TransactionEntity>.unmodifiable(sorted);
        }
        return List<TransactionEntity>.unmodifiable(sorted.take(limit));
      },
    );
  }
}
