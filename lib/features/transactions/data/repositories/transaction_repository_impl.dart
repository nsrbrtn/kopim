import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required db.AppDatabase database,
    required TransactionDao transactionDao,
    required SavingGoalDao savingGoalDao,
    required GoalContributionDao goalContributionDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _transactionDao = transactionDao,
       _savingGoalDao = savingGoalDao,
       _contributionDao = goalContributionDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final TransactionDao _transactionDao;
  final SavingGoalDao _savingGoalDao;
  final GoalContributionDao _contributionDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'transaction';
  static const String _savingGoalEntityType = 'saving_goal';

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
      await _handleSavingGoalRollback(row, now);
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

  Future<void> _handleSavingGoalRollback(
    db.TransactionRow row,
    DateTime deletedAt,
  ) async {
    final String? goalId = row.savingGoalId;
    if (goalId == null) {
      return;
    }
    final db.GoalContributionRow? contribution = await _contributionDao
        .findByTransactionId(row.id);
    if (contribution == null) {
      await _contributionDao.deleteByTransactionId(row.id);
      return;
    }
    final SavingGoal? goal = await _savingGoalDao.findById(goalId);
    if (goal == null) {
      await _contributionDao.deleteById(contribution.id);
      return;
    }
    final int updatedAmount = (goal.currentAmount - contribution.amount).clamp(
      0,
      goal.targetAmount,
    );
    final SavingGoal updatedGoal = goal.copyWith(
      currentAmount: updatedAmount,
      updatedAt: deletedAt,
    );
    await _savingGoalDao.upsert(updatedGoal);
    await _outboxDao.enqueue(
      entityType: _savingGoalEntityType,
      entityId: updatedGoal.id,
      operation: OutboxOperation.upsert,
      payload: _mapGoalPayload(updatedGoal),
    );
    await _contributionDao.deleteById(contribution.id);
  }

  Map<String, dynamic> _mapTransactionPayload(TransactionEntity transaction) {
    final Map<String, dynamic> json = transaction.toJson();
    json['createdAt'] = transaction.createdAt.toIso8601String();
    json['updatedAt'] = transaction.updatedAt.toIso8601String();
    json['date'] = transaction.date.toIso8601String();
    json['savingGoalId'] = transaction.savingGoalId;
    return json;
  }

  Map<String, dynamic> _mapGoalPayload(SavingGoal goal) {
    final Map<String, dynamic> json = goal.toJson();
    json['createdAt'] = goal.createdAt.toIso8601String();
    json['updatedAt'] = goal.updatedAt.toIso8601String();
    json['archivedAt'] = goal.archivedAt?.toIso8601String();
    return json;
  }

  TransactionEntity _mapToDomain(db.TransactionRow row) {
    return TransactionEntity(
      id: row.id,
      accountId: row.accountId,
      categoryId: row.categoryId,
      savingGoalId: row.savingGoalId,
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
