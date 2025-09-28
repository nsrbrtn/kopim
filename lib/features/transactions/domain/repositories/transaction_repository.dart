import 'package:kopim/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchTransactions();
  Future<List<TransactionEntity>> loadTransactions();
  Future<TransactionEntity?> findById(String id);
  Future<void> upsert(TransactionEntity transaction);
  Future<void> softDelete(String id);
}
