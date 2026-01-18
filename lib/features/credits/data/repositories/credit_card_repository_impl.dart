import 'dart:async';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_card_repository.dart';

class CreditCardRepositoryImpl implements CreditCardRepository {
  CreditCardRepositoryImpl({
    required db.AppDatabase database,
    required CreditCardDao creditCardDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _creditCardDao = creditCardDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final CreditCardDao _creditCardDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'credit_card';

  @override
  Stream<List<CreditCardEntity>> watchCreditCards() {
    return _creditCardDao.watchActiveCreditCards().map(
      (List<db.CreditCardRow> rows) =>
          rows.map(_creditCardDao.mapRowToEntity).toList(growable: false),
    );
  }

  @override
  Future<List<CreditCardEntity>> getCreditCards() async {
    final List<db.CreditCardRow> rows = await _creditCardDao
        .getActiveCreditCards();
    return rows.map(_creditCardDao.mapRowToEntity).toList(growable: false);
  }

  @override
  Future<CreditCardEntity?> getByAccountId(String accountId) async {
    final db.CreditCardRow? row = await _creditCardDao.findByAccountId(
      accountId,
    );
    if (row == null) return null;
    return _creditCardDao.mapRowToEntity(row);
  }

  @override
  Future<void> addCreditCard(CreditCardEntity creditCard) async {
    await _upsert(creditCard);
  }

  @override
  Future<void> updateCreditCard(CreditCardEntity creditCard) async {
    await _upsert(creditCard);
  }

  @override
  Future<void> deleteCreditCard(String id) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _creditCardDao.markDeleted(id, now);
      final db.CreditCardRow? row = await _creditCardDao.findById(id);
      if (row == null) return;
      final CreditCardEntity entity = _creditCardDao
          .mapRowToEntity(row)
          .copyWith(isDeleted: true, updatedAt: now);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: _mapPayload(entity),
      );
    });
  }

  Future<void> _upsert(CreditCardEntity creditCard) async {
    final DateTime now = DateTime.now();
    final int creditLimitScale =
        creditCard.creditLimitScale ??
        await _resolveAccountScale(creditCard.accountId);
    final CreditCardEntity toPersist = creditCard.copyWith(
      updatedAt: now,
      creditLimitScale: creditLimitScale,
    );
    await _database.transaction(() async {
      await _creditCardDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapPayload(toPersist),
      );
    });
  }

  Future<int> _resolveAccountScale(String accountId) async {
    final db.AccountRow? account =
        await (_database.select(_database.accounts)
              ..where((db.Accounts tbl) => tbl.id.equals(accountId)))
            .getSingleOrNull();
    if (account == null) {
      return 2;
    }
    return account.currencyScale;
  }

  Map<String, dynamic> _mapPayload(CreditCardEntity creditCard) {
    final Map<String, dynamic> json = creditCard.toJson();
    json['createdAt'] = creditCard.createdAt.toIso8601String();
    json['updatedAt'] = creditCard.updatedAt.toIso8601String();
    json['creditLimitMinor'] = creditCard.creditLimitMinor?.toString();
    json['creditLimitScale'] = creditCard.creditLimitScale;
    return json;
  }
}
