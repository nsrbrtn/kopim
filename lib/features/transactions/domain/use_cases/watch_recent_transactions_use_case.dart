import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchRecentTransactionsUseCase {
  WatchRecentTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Stream<List<TransactionEntity>> call({int limit = 5}) {
    return _repository.watchTransactions().map(
      (List<TransactionEntity> transactions) {
        if (transactions.isEmpty) {
          return const <TransactionEntity>[];
        }

        final List<TransactionEntity> sorted =
            List<TransactionEntity>.from(transactions)
              ..sort(
                (TransactionEntity a, TransactionEntity b) =>
                    b.date.compareTo(a.date),
              );

        if (limit <= 0 || sorted.length <= limit) {
          return List<TransactionEntity>.unmodifiable(sorted);
        }

        return List<TransactionEntity>.unmodifiable(sorted.take(limit));
      },
    );
  }
}
