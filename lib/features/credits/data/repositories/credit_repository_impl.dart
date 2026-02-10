import 'dart:async';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';

class CreditRepositoryImpl implements CreditRepository {
  CreditRepositoryImpl({
    required db.AppDatabase database,
    required CreditDao creditDao,
    required CreditPaymentDao creditPaymentDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _creditDao = creditDao,
       _creditPaymentDao = creditPaymentDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final CreditDao _creditDao;
  final CreditPaymentDao _creditPaymentDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'credit';

  @override
  Stream<List<CreditEntity>> watchCredits() {
    return _creditDao.watchActiveCredits().map(
      (List<db.CreditRow> rows) => rows.map(_creditDao.mapRowToEntity).toList(),
    );
  }

  @override
  Future<List<CreditEntity>> getCredits() async {
    final List<db.CreditRow> rows = await _creditDao.getActiveCredits();
    return rows.map(_creditDao.mapRowToEntity).toList();
  }

  @override
  Future<CreditEntity?> getCreditByAccountId(String accountId) async {
    final db.CreditRow? row = await _creditDao.findByAccountId(accountId);
    if (row == null) return null;
    return _creditDao.mapRowToEntity(row);
  }

  @override
  Future<CreditEntity?> getCreditByCategoryId(String categoryId) async {
    final db.CreditRow? row = await _creditDao.findByCategoryId(categoryId);
    if (row == null) return null;
    return _creditDao.mapRowToEntity(row);
  }

  @override
  Future<void> addCredit(CreditEntity credit) async {
    await _upsert(credit);
  }

  @override
  Future<void> updateCredit(CreditEntity credit) async {
    await _upsert(credit);
  }

  @override
  Future<void> deleteCredit(String id) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _creditPaymentDao.deletePaymentArtifactsByCreditId(id);
      await _creditDao.markDeleted(id, now);
      final db.CreditRow? row = await _creditDao.findById(id);
      if (row == null) return;
      final CreditEntity entity = _creditDao
          .mapRowToEntity(row)
          .copyWith(isDeleted: true, updatedAt: now);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: _mapCreditPayload(entity),
      );
    });
  }

  Future<void> _upsert(CreditEntity credit) async {
    final DateTime now = DateTime.now();
    final int totalAmountScale =
        credit.totalAmountScale ?? await _resolveAccountScale(credit.accountId);
    final CreditEntity toPersist = credit.copyWith(
      updatedAt: now,
      totalAmountScale: totalAmountScale,
    );
    await _database.transaction(() async {
      await _creditDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapCreditPayload(toPersist),
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

  Map<String, dynamic> _mapCreditPayload(CreditEntity credit) {
    final Map<String, dynamic> json = credit.toJson();
    json['startDate'] = credit.startDate.toIso8601String();
    json['updatedAt'] = credit.updatedAt.toIso8601String();
    json['createdAt'] = credit.createdAt.toIso8601String();
    json['totalAmountMinor'] = credit.totalAmountMinor?.toString();
    json['totalAmountScale'] = credit.totalAmountScale;
    return json;
  }

  @override
  Future<void> addSchedule(List<CreditPaymentScheduleEntity> schedule) async {
    await _creditPaymentDao.insertSchedule(schedule);
  }

  @override
  Future<List<CreditPaymentScheduleEntity>> getSchedule(String creditId) {
    return _creditPaymentDao.getSchedule(creditId);
  }

  @override
  Stream<List<CreditPaymentScheduleEntity>> watchSchedule(String creditId) {
    return _creditPaymentDao.watchSchedule(creditId);
  }

  @override
  Future<void> updateScheduleItem(CreditPaymentScheduleEntity item) async {
    await _creditPaymentDao.updateScheduleItem(item);
  }

  @override
  Future<void> addPaymentGroup(CreditPaymentGroupEntity group) async {
    await _creditPaymentDao.insertPaymentGroup(group);
  }

  @override
  Future<List<CreditPaymentGroupEntity>> getPaymentGroups(String creditId) {
    return _creditPaymentDao.getPaymentGroups(creditId);
  }
}
