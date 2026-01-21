import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  DebtRepositoryImpl({
    required db.AppDatabase database,
    required DebtDao debtDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _debtDao = debtDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final DebtDao _debtDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'debt';

  @override
  Stream<List<DebtEntity>> watchDebts() {
    return _debtDao.watchActiveDebts().map(
      (List<db.DebtRow> rows) => rows.map(_debtDao.mapRowToEntity).toList(),
    );
  }

  @override
  Future<List<DebtEntity>> getDebts() async {
    final List<db.DebtRow> rows = await _debtDao.getActiveDebts();
    return rows.map(_debtDao.mapRowToEntity).toList();
  }

  @override
  Future<void> addDebt(DebtEntity debt) async {
    await _upsert(debt);
  }

  @override
  Future<void> updateDebt(DebtEntity debt) async {
    await _upsert(debt);
  }

  @override
  Future<void> deleteDebt(String id) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _debtDao.markDeleted(id, now);
      final db.DebtRow? row = await _debtDao.findById(id);
      if (row == null) return;
      final DebtEntity entity = _debtDao
          .mapRowToEntity(row)
          .copyWith(isDeleted: true, updatedAt: now);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: _mapDebtPayload(entity),
      );
    });
  }

  Future<void> _upsert(DebtEntity debt) async {
    final DateTime now = DateTime.now();
    final int amountScale =
        debt.amountScale ?? await _resolveAccountScale(debt.accountId);
    final DebtEntity toPersist = debt.copyWith(
      updatedAt: now,
      amountScale: amountScale,
    );
    await _database.transaction(() async {
      await _debtDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapDebtPayload(toPersist),
      );
    });
  }

  Future<int> _resolveAccountScale(String accountId) async {
    final db.AccountRow? account = await (_database.select(
      _database.accounts,
    )..where((db.Accounts tbl) => tbl.id.equals(accountId))).getSingleOrNull();
    if (account == null) {
      return 2;
    }
    return account.currencyScale;
  }

  Map<String, dynamic> _mapDebtPayload(DebtEntity debt) {
    final Map<String, dynamic> json = debt.toJson();
    json['dueDate'] = debt.dueDate.toIso8601String();
    json['updatedAt'] = debt.updatedAt.toIso8601String();
    json['createdAt'] = debt.createdAt.toIso8601String();
    json['amountMinor'] = debt.amountMinor?.toString();
    json['amountScale'] = debt.amountScale;
    return json;
  }
}
