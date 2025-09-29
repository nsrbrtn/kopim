import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Watches the most recent transactions stored locally with a configurable limit.
abstract class WatchRecentTransactionsUseCase {
  /// Emits the latest transactions ordered from newest to oldest.
  Stream<List<TransactionEntity>> call({int limit});
}
