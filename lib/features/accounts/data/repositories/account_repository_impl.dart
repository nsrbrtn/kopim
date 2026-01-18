import 'dart:async';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required db.AppDatabase database,
    required AccountDao accountDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _accountDao = accountDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final AccountDao _accountDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'account';

  @override
  Stream<List<AccountEntity>> watchAccounts() {
    return _accountDao.watchActiveAccounts().map(
      (List<db.AccountRow> rows) =>
          rows.map(_mapToDomain).toList(growable: false),
    );
  }

  @override
  Future<List<AccountEntity>> loadAccounts() async {
    final List<db.AccountRow> rows = await _accountDao.getActiveAccounts();
    return rows.map(_mapToDomain).toList(growable: false);
  }

  @override
  Future<AccountEntity?> findById(String id) async {
    final db.AccountRow? row = await _accountDao.findById(id);
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<void> upsert(AccountEntity account) async {
    final DateTime now = DateTime.now();
    final AccountEntity toPersist = account.copyWith(updatedAt: now);
    await _database.transaction(() async {
      if (toPersist.isPrimary) {
        await _accountDao.clearPrimaryExcept(toPersist.id, now);
      }
      await _accountDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapAccountPayload(toPersist),
      );
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _accountDao.markDeleted(id, now);
      final db.AccountRow? row = await _accountDao.findById(id);
      if (row == null) return;
      final Map<String, dynamic> payload = _mapAccountPayload(
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

  Map<String, dynamic> _mapAccountPayload(AccountEntity account) {
    final Map<String, dynamic> json = account.toJson();
    json['updatedAt'] = account.updatedAt.toIso8601String();
    json['createdAt'] = account.createdAt.toIso8601String();
    json['isPrimary'] = account.isPrimary;
    json['color'] = account.color;
    json['gradientId'] = account.gradientId;
    json['iconName'] = account.iconName;
    json['iconStyle'] = account.iconStyle;
    json['openingBalance'] = account.openingBalance;
    return json;
  }

  AccountEntity _mapToDomain(db.AccountRow row) {
    return AccountEntity(
      id: row.id,
      name: row.name,
      balance: row.balance,
      openingBalance: row.openingBalance,
      currency: row.currency,
      type: row.type,
      color: row.color,
      gradientId: row.gradientId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      isPrimary: row.isPrimary,
      isHidden: row.isHidden,
      iconName: row.iconName,
      iconStyle: row.iconStyle,
    );
  }
}
