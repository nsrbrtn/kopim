import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchRecentTransactionsUseCase {
  WatchRecentTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Stream<List<TransactionEntity>> call({int limit = 5}) {
    final int? normalizedLimit = limit > 0 ? limit : null;
    return _repository
        .watchRecentTransactions(limit: normalizedLimit)
        .map(List<TransactionEntity>.unmodifiable);
  }
}
