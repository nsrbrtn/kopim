import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
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
  static const Duration _balanceUpdateClockSkew = Duration(milliseconds: 1);

  static const String _entityType = 'transaction';
  static const String _savingGoalEntityType = 'saving_goal';

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    return _transactionDao.watchActiveTransactions().map(
      (List<db.TransactionRow> rows) =>
          List<TransactionEntity>.unmodifiable(rows.map(_mapToDomain)),
    );
  }

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    final Stream<List<db.TransactionRow>> rowsStream = _transactionDao
        .watchRecentTransactions(limit: limit);
    return rowsStream.map(
      (List<db.TransactionRow> rows) =>
          List<TransactionEntity>.unmodifiable(rows.map(_mapToDomain)),
    );
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    return _transactionDao
        .watchAccountMonthlyTotals(start: start, end: end)
        .map(
          (List<AccountMonthlyTotalsRow> rows) => rows
              .map(
                (AccountMonthlyTotalsRow row) => AccountMonthlyTotals(
                  accountId: row.accountId,
                  income: row.income,
                  expense: row.expense,
                ),
              )
              .toList(growable: false),
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
      final db.TransactionRow? previousRow = await _transactionDao.findById(
        toPersist.id,
      );
      final TransactionEntity? previous =
          previousRow != null ? _mapToDomain(previousRow) : null;
      await _transactionDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapTransactionPayload(toPersist),
      );
      await _applyAccountBalanceDelta(
        previous: previous,
        next: toPersist,
        updatedAt: now.add(_balanceUpdateClockSkew),
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
      await _applyAccountBalanceDelta(
        previous: _mapToDomain(row),
        next: null,
        updatedAt: now.add(_balanceUpdateClockSkew),
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
      transferAccountId: row.transferAccountId,
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

  Future<void> _applyAccountBalanceDelta({
    required TransactionEntity? previous,
    required TransactionEntity? next,
    required DateTime updatedAt,
  }) async {
    final Map<String, double> deltas = <String, double>{};
    void accumulate(TransactionEntity tx, double sign) {
      if (tx.isDeleted) return;
      final TransactionType type = parseTransactionType(tx.type);
      switch (type) {
        case TransactionType.income:
          deltas.update(tx.accountId, (double v) => v + sign * tx.amount,
              ifAbsent: () => sign * tx.amount);
          break;
        case TransactionType.expense:
          deltas.update(tx.accountId, (double v) => v - sign * tx.amount,
              ifAbsent: () => -sign * tx.amount);
          break;
        case TransactionType.transfer:
          deltas.update(tx.accountId, (double v) => v - sign * tx.amount,
              ifAbsent: () => -sign * tx.amount);
          final String? targetId = tx.transferAccountId;
          if (targetId != null && targetId != tx.accountId) {
            deltas.update(
              targetId,
              (double v) => v + sign * tx.amount,
              ifAbsent: () => sign * tx.amount,
            );
          }
          break;
      }
    }

    if (previous != null) {
      accumulate(previous, -1);
    }
    if (next != null) {
      accumulate(next, 1);
    }

    for (final MapEntry<String, double> entry in deltas.entries) {
      if (entry.value == 0) continue;
      final db.AccountRow? account = await (_database.select(_database.accounts)
            ..where((db.$AccountsTable tbl) => tbl.id.equals(entry.key)))
          .getSingleOrNull();
      if (account == null || account.isDeleted) continue;
      final double newBalance = account.balance + entry.value;
      await (_database.update(_database.accounts)
            ..where((db.$AccountsTable tbl) => tbl.id.equals(entry.key)))
          .write(
        db.AccountsCompanion(
          balance: Value<double>(newBalance),
          updatedAt: Value<DateTime>(updatedAt),
        ),
      );
    }
  }
}
