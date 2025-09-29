import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required db.AppDatabase database,
    required TransactionDao transactionDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _transactionDao = transactionDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final TransactionDao _transactionDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'transaction';

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    return _transactionDao.watchActiveTransactions().map(
      (List<db.TransactionRow> rows) =>
          rows.map(_mapToDomain).toList(growable: false),
    );
  }

  @override
  Future<List<TransactionEntity>> loadTransactions() async {
    final List<db.TransactionRow> rows = await _transactionDao
        .getActiveTransactions();
    return rows.map(_mapToDomain).toList(growable: false);
  }

  @override
  Future<TransactionEntity?> findById(String id) async {
    final db.TransactionRow? row = await _transactionDao.findById(id);
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<void> upsert(TransactionEntity transaction) async {
    final DateTime now = DateTime.now();
    final TransactionEntity toPersist = transaction.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _transactionDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapTransactionPayload(toPersist),
      );
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _transactionDao.markDeleted(id, now);
      final db.TransactionRow? row = await _transactionDao.findById(id);
      if (row == null) return;
      final Map<String, dynamic> payload = _mapTransactionPayload(
        _mapToDomain(row).copyWith(isDeleted: true, updatedAt: now),
      );
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: payload,
      );
    });
  }

  Map<String, dynamic> _mapTransactionPayload(TransactionEntity transaction) {
    final Map<String, dynamic> json = transaction.toJson();
    json['createdAt'] = transaction.createdAt.toIso8601String();
    json['updatedAt'] = transaction.updatedAt.toIso8601String();
    json['date'] = transaction.date.toIso8601String();
    return json;
  }

  TransactionEntity _mapToDomain(db.TransactionRow row) {
    return TransactionEntity(
      id: row.id,
      accountId: row.accountId,
      categoryId: row.categoryId,
      amount: row.amount,
      date: row.date,
      note: row.note,
      type: row.type,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
