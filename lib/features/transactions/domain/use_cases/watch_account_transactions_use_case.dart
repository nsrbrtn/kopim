import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchAccountTransactionsUseCase {
  WatchAccountTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Stream<List<TransactionEntity>> call({required String accountId}) {
    return _repository.watchRecentTransactions().map((
      List<TransactionEntity> transactions,
    ) {
      final Iterable<TransactionEntity> filtered = transactions.where(
        (TransactionEntity transaction) =>
            transaction.accountId == accountId ||
            transaction.transferAccountId == accountId,
      );
      return List<TransactionEntity>.unmodifiable(filtered);
    });
  }
}
