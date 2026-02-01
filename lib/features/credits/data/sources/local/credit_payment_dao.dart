import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';

class CreditPaymentDao {
  CreditPaymentDao(this._db);

  final db.AppDatabase _db;

  Future<void> insertSchedule(List<CreditPaymentScheduleEntity> items) async {
    if (items.isEmpty) return;
    await _db.batch((Batch batch) {
      batch.insertAll(
        _db.creditPaymentSchedules,
        items.map(_mapScheduleToCompanion).toList(),
      );
    });
  }

  Future<List<CreditPaymentScheduleEntity>> getSchedule(String creditId) async {
    final List<db.CreditPaymentScheduleRow> rows =
        await (_db.select(_db.creditPaymentSchedules)..where(
              (db.CreditPaymentSchedules tbl) => tbl.creditId.equals(creditId),
            ))
            .get();

    rows.sort(
      (db.CreditPaymentScheduleRow a, db.CreditPaymentScheduleRow b) =>
          a.dueDate.compareTo(b.dueDate),
    );

    return rows.map(_mapRowToScheduleEntity).toList();
  }

  Stream<List<CreditPaymentScheduleEntity>> watchSchedule(String creditId) {
    return (_db.select(
      _db.creditPaymentSchedules,
    )..where((db.CreditPaymentSchedules tbl) =>
            tbl.creditId.equals(creditId)))
        .watch()
        .map((List<db.CreditPaymentScheduleRow> rows) {
      final List<db.CreditPaymentScheduleRow> items = rows.toList()
        ..sort(
          (db.CreditPaymentScheduleRow a, db.CreditPaymentScheduleRow b) =>
              a.dueDate.compareTo(b.dueDate),
        );
      return items.map(_mapRowToScheduleEntity).toList();
    });
  }

  Future<void> updateScheduleItem(CreditPaymentScheduleEntity item) async {
    await _db
        .update(_db.creditPaymentSchedules)
        .replace(_mapScheduleToCompanion(item));
  }

  Future<void> insertPaymentGroup(CreditPaymentGroupEntity group) async {
    await _db.into(_db.creditPaymentGroups).insert(_mapGroupToCompanion(group));
  }

  Future<List<CreditPaymentGroupEntity>> getPaymentGroups(
    String creditId,
  ) async {
    final List<db.CreditPaymentGroupRow> rows =
        await (_db.select(_db.creditPaymentGroups)..where(
              (db.CreditPaymentGroups tbl) => tbl.creditId.equals(creditId),
            ))
            .get();
    rows.sort(
      (db.CreditPaymentGroupRow a, db.CreditPaymentGroupRow b) =>
          b.paidAt.compareTo(a.paidAt),
    ); // Descending
    return rows.map(_mapRowToGroupEntity).toList();
  }

  db.CreditPaymentSchedulesCompanion _mapScheduleToCompanion(
    CreditPaymentScheduleEntity item,
  ) {
    return db.CreditPaymentSchedulesCompanion(
      id: Value<String>(item.id),
      creditId: Value<String>(item.creditId),
      periodKey: Value<String>(item.periodKey),
      dueDate: Value<DateTime>(item.dueDate),
      status: Value<String>(item.status.name),
      principalAmountMinor: Value<String>(
        item.principalAmount.minor.toString(),
      ),
      interestAmountMinor: Value<String>(item.interestAmount.minor.toString()),
      totalAmountMinor: Value<String>(item.totalAmount.minor.toString()),
      amountScale: Value<int>(item.totalAmount.scale),
      principalPaidMinor: Value<String>(item.principalPaid.minor.toString()),
      interestPaidMinor: Value<String>(item.interestPaid.minor.toString()),
      paidAt: Value<DateTime?>(item.paidAt),
      updatedAt: Value<DateTime>(DateTime.now()),
    );
  }

  CreditPaymentScheduleEntity _mapRowToScheduleEntity(
    db.CreditPaymentScheduleRow row,
  ) {
    final int scale = row.amountScale;
    const String currency = 'XXX'; // Or fetch credit currency?
    // Schedule assumes same currency as credit.
    // Money object usually needs currency.
    // For now use 'XXX' or we need to join with Credits table to get currency?
    // Or just store currency in Schedule?
    // Plan V3 says "Currency Scale" stored.
    // I'll stick to 'XXX' and caller resolves currency or reuse scale.

    return CreditPaymentScheduleEntity(
      id: row.id,
      creditId: row.creditId,
      periodKey: row.periodKey,
      dueDate: row.dueDate,
      status: CreditPaymentStatus.values.byName(row.status),
      principalAmount: Money.fromMinor(
        BigInt.parse(row.principalAmountMinor),
        currency: currency,
        scale: scale,
      ),
      interestAmount: Money.fromMinor(
        BigInt.parse(row.interestAmountMinor),
        currency: currency,
        scale: scale,
      ),
      totalAmount: Money.fromMinor(
        BigInt.parse(row.totalAmountMinor),
        currency: currency,
        scale: scale,
      ),
      principalPaid: Money.fromMinor(
        BigInt.parse(row.principalPaidMinor),
        currency: currency,
        scale: scale,
      ),
      interestPaid: Money.fromMinor(
        BigInt.parse(row.interestPaidMinor),
        currency: currency,
        scale: scale,
      ),
      paidAt: row.paidAt,
    );
  }

  db.CreditPaymentGroupsCompanion _mapGroupToCompanion(
    CreditPaymentGroupEntity group,
  ) {
    return db.CreditPaymentGroupsCompanion(
      id: Value<String>(group.id),
      creditId: Value<String>(group.creditId),
      sourceAccountId: Value<String>(group.sourceAccountId),
      scheduleItemId: Value<String?>(group.scheduleItemId),
      paidAt: Value<DateTime>(group.paidAt),
      totalOutflowMinor: Value<String>(group.totalOutflow.minor.toString()),
      totalOutflowScale: Value<int>(group.totalOutflow.scale),
      principalPaidMinor: Value<String>(group.principalPaid.minor.toString()),
      interestPaidMinor: Value<String>(group.interestPaid.minor.toString()),
      feesPaidMinor: Value<String>(group.feesPaid.minor.toString()),
      note: Value<String?>(group.note),
      idempotencyKey: Value<String?>(group.idempotencyKey),
      updatedAt: Value<DateTime>(DateTime.now()),
    );
  }

  CreditPaymentGroupEntity _mapRowToGroupEntity(db.CreditPaymentGroupRow row) {
    final int scale = row.totalOutflowScale;
    const String currency = 'XXX';

    return CreditPaymentGroupEntity(
      id: row.id,
      creditId: row.creditId,
      sourceAccountId: row.sourceAccountId,
      scheduleItemId: row.scheduleItemId,
      paidAt: row.paidAt,
      totalOutflow: Money.fromMinor(
        BigInt.parse(row.totalOutflowMinor),
        currency: currency,
        scale: scale,
      ),
      principalPaid: Money.fromMinor(
        BigInt.parse(row.principalPaidMinor),
        currency: currency,
        scale: scale,
      ),
      interestPaid: Money.fromMinor(
        BigInt.parse(row.interestPaidMinor),
        currency: currency,
        scale: scale,
      ),
      feesPaid: Money.fromMinor(
        BigInt.parse(row.feesPaidMinor),
        currency: currency,
        scale: scale,
      ),
      note: row.note,
      idempotencyKey: row.idempotencyKey,
    );
  }
}
