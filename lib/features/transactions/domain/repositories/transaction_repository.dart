import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchTransactions();
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit});
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  });
  Future<List<TransactionEntity>> loadTransactions();
  Future<TransactionEntity?> findById(String id);
  Future<void> upsert(TransactionEntity transaction);
  Future<void> softDelete(String id);
}
