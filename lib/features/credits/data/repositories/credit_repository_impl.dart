import 'dart:async';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/validators/credit_payment_schedule_validator.dart';

class CreditRepositoryImpl implements CreditRepository {
  CreditRepositoryImpl({
    required db.AppDatabase database,
    required CreditDao creditDao,
    required CreditPaymentDao creditPaymentDao,
    required OutboxDao outboxDao,
    CreditPaymentScheduleValidator? scheduleValidator,
  }) : _database = database,
       _creditDao = creditDao,
       _creditPaymentDao = creditPaymentDao,
       _outboxDao = outboxDao,
       _scheduleValidator =
           scheduleValidator ?? const CreditPaymentScheduleValidator();

  final db.AppDatabase _database;
  final CreditDao _creditDao;
  final CreditPaymentDao _creditPaymentDao;
  final OutboxDao _outboxDao;
  final CreditPaymentScheduleValidator _scheduleValidator;

  static const String _entityType = 'credit';
  static const String _paymentGroupEntityType = 'credit_payment_group';
  static const String _paymentScheduleEntityType = 'credit_payment_schedule';

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
      final List<CreditPaymentGroupEntity> existingGroups =
          await _creditPaymentDao.getPaymentGroups(id);
      final List<CreditPaymentScheduleEntity> existingSchedule =
          await _creditPaymentDao.getSchedule(id);
      await _creditPaymentDao.markPaymentArtifactsDeletedByCreditId(id, now);
      await _creditDao.markDeleted(id, now);
      final db.CreditRow? row = await _creditDao.findById(id);
      for (final CreditPaymentGroupEntity group in existingGroups) {
        await _outboxDao.enqueue(
          entityType: _paymentGroupEntityType,
          entityId: group.id,
          operation: OutboxOperation.delete,
          payload: _mapPaymentGroupPayload(
            group.copyWith(isDeleted: true, updatedAt: now),
          ),
        );
      }
      for (final CreditPaymentScheduleEntity item in existingSchedule) {
        await _outboxDao.enqueue(
          entityType: _paymentScheduleEntityType,
          entityId: item.id,
          operation: OutboxOperation.delete,
          payload: _mapPaymentSchedulePayload(
            item.copyWith(isDeleted: true, updatedAt: now),
          ),
        );
      }
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
    for (final CreditPaymentScheduleEntity item in schedule) {
      _scheduleValidator.validate(item);
    }
    final DateTime now = DateTime.now().toUtc();
    final List<CreditPaymentScheduleEntity> toPersist = schedule
        .map(
          (CreditPaymentScheduleEntity item) =>
              item.copyWith(createdAt: item.createdAt ?? now, updatedAt: now),
        )
        .toList(growable: false);
    await _database.transaction(() async {
      await _creditPaymentDao.upsertSchedule(toPersist);
      for (final CreditPaymentScheduleEntity item in toPersist) {
        await _outboxDao.enqueue(
          entityType: _paymentScheduleEntityType,
          entityId: item.id,
          operation: OutboxOperation.upsert,
          payload: _mapPaymentSchedulePayload(item),
        );
      }
    });
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
    _scheduleValidator.validate(item);
    final DateTime now = DateTime.now().toUtc();
    final CreditPaymentScheduleEntity toPersist = item.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _creditPaymentDao.updateScheduleItem(toPersist);
      await _outboxDao.enqueue(
        entityType: _paymentScheduleEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapPaymentSchedulePayload(toPersist),
      );
    });
  }

  @override
  Future<void> addPaymentGroup(CreditPaymentGroupEntity group) async {
    final DateTime now = DateTime.now().toUtc();
    final CreditPaymentGroupEntity toPersist = group.copyWith(
      createdAt: group.createdAt ?? now,
      updatedAt: now,
    );
    await _database.transaction(() async {
      await _creditPaymentDao.insertPaymentGroup(toPersist);
      await _outboxDao.enqueue(
        entityType: _paymentGroupEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapPaymentGroupPayload(toPersist),
      );
    });
  }

  @override
  Future<bool> addPaymentGroupIfAbsent(CreditPaymentGroupEntity group) async {
    final DateTime now = DateTime.now().toUtc();
    final CreditPaymentGroupEntity toPersist = group.copyWith(
      createdAt: group.createdAt ?? now,
      updatedAt: now,
    );
    bool inserted = false;
    await _database.transaction(() async {
      inserted = await _creditPaymentDao.insertPaymentGroupIfAbsent(toPersist);
      if (!inserted) {
        return;
      }
      await _outboxDao.enqueue(
        entityType: _paymentGroupEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapPaymentGroupPayload(toPersist),
      );
    });
    return inserted;
  }

  @override
  Future<void> updatePaymentGroup(CreditPaymentGroupEntity group) async {
    final DateTime now = DateTime.now().toUtc();
    final CreditPaymentGroupEntity toPersist = group.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _creditPaymentDao.updatePaymentGroup(toPersist);
      await _outboxDao.enqueue(
        entityType: _paymentGroupEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapPaymentGroupPayload(toPersist),
      );
    });
  }

  @override
  Future<List<CreditPaymentGroupEntity>> getPaymentGroups(String creditId) {
    return _creditPaymentDao.getPaymentGroups(creditId);
  }

  @override
  Future<CreditPaymentGroupEntity?> findPaymentGroupById(String groupId) {
    return _creditPaymentDao.findPaymentGroupById(groupId);
  }

  @override
  Future<CreditPaymentGroupEntity?> findPaymentGroupByIdempotencyKey({
    required String creditId,
    required String idempotencyKey,
  }) {
    return _creditPaymentDao.findPaymentGroupByIdempotencyKey(
      creditId: creditId,
      idempotencyKey: idempotencyKey,
    );
  }

  Map<String, dynamic> _mapPaymentGroupPayload(CreditPaymentGroupEntity group) {
    return <String, dynamic>{
      'id': group.id,
      'creditId': group.creditId,
      'sourceAccountId': group.sourceAccountId,
      'scheduleItemId': group.scheduleItemId,
      'paidAt': group.paidAt.toIso8601String(),
      'totalOutflowMinor': group.totalOutflow.minor.toString(),
      'totalOutflowScale': group.totalOutflow.scale,
      'principalPaidMinor': group.principalPaid.minor.toString(),
      'interestPaidMinor': group.interestPaid.minor.toString(),
      'feesPaidMinor': group.feesPaid.minor.toString(),
      'note': group.note,
      'idempotencyKey': group.idempotencyKey,
      'createdAt': (group.createdAt ?? group.paidAt).toIso8601String(),
      'updatedAt': (group.updatedAt ?? group.paidAt).toIso8601String(),
      'isDeleted': group.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapPaymentSchedulePayload(
    CreditPaymentScheduleEntity item,
  ) {
    return <String, dynamic>{
      'id': item.id,
      'creditId': item.creditId,
      'periodKey': item.periodKey,
      'dueDate': item.dueDate.toIso8601String(),
      'status': item.status.name,
      'principalAmountMinor': item.principalAmount.minor.toString(),
      'interestAmountMinor': item.interestAmount.minor.toString(),
      'totalAmountMinor': item.totalAmount.minor.toString(),
      'amountScale': item.totalAmount.scale,
      'principalPaidMinor': item.principalPaid.minor.toString(),
      'interestPaidMinor': item.interestPaid.minor.toString(),
      'paidAt': item.paidAt?.toIso8601String(),
      'createdAt': (item.createdAt ?? item.dueDate).toIso8601String(),
      'updatedAt': (item.updatedAt ?? item.dueDate).toIso8601String(),
      'isDeleted': item.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }
}
