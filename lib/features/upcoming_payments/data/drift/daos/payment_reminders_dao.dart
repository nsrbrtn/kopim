import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/upcoming_payments/data/drift/mappers/payment_reminder_mapper.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';

class PaymentRemindersDao {
  PaymentRemindersDao(
    this._db, {
    PaymentReminderMapper mapper = const PaymentReminderMapper(),
  }) : _mapper = mapper;

  final db.AppDatabase _db;
  final PaymentReminderMapper _mapper;

  Stream<List<PaymentReminder>> watchAll() {
    final SimpleSelectStatement<
      db.$PaymentRemindersTable,
      db.PaymentReminderRow
    >
    query = _db.select(_db.paymentReminders)
      ..orderBy(<OrderClauseGenerator<db.$PaymentRemindersTable>>[
        (db.$PaymentRemindersTable tbl) =>
            OrderingTerm(expression: tbl.whenAt, mode: OrderingMode.asc),
      ]);
    return query.watch().map(_mapRows);
  }

  Stream<List<PaymentReminder>> watchUpcoming({int? limit}) {
    final SimpleSelectStatement<
      db.$PaymentRemindersTable,
      db.PaymentReminderRow
    >
    query = _db.select(_db.paymentReminders)
      ..where((db.$PaymentRemindersTable tbl) => tbl.isDone.equals(false))
      ..orderBy(<OrderClauseGenerator<db.$PaymentRemindersTable>>[
        (db.$PaymentRemindersTable tbl) =>
            OrderingTerm(expression: tbl.whenAt, mode: OrderingMode.asc),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.watch().map(_mapRows);
  }

  Future<List<PaymentReminder>> getAll() async {
    final SimpleSelectStatement<
      db.$PaymentRemindersTable,
      db.PaymentReminderRow
    >
    query = _db.select(_db.paymentReminders)
      ..orderBy(<OrderClauseGenerator<db.$PaymentRemindersTable>>[
        (db.$PaymentRemindersTable tbl) =>
            OrderingTerm(expression: tbl.whenAt, mode: OrderingMode.asc),
      ]);
    final List<db.PaymentReminderRow> rows = await query.get();
    return rows.map(_mapper.mapRowToEntity).toList(growable: false);
  }

  Future<PaymentReminder?> getById(String id) async {
    final SimpleSelectStatement<
      db.$PaymentRemindersTable,
      db.PaymentReminderRow
    >
    query = _db.select(_db.paymentReminders)
      ..where((db.$PaymentRemindersTable tbl) => tbl.id.equals(id))
      ..limit(1);
    final db.PaymentReminderRow? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapper.mapRowToEntity(row);
  }

  Future<void> upsert(PaymentReminder reminder) async {
    _validate(reminder);
    await _db
        .into(_db.paymentReminders)
        .insertOnConflictUpdate(_mapper.mapEntityToCompanion(reminder));
  }

  Future<void> delete(String id) {
    return (_db.delete(
      _db.paymentReminders,
    )..where((db.$PaymentRemindersTable tbl) => tbl.id.equals(id))).go();
  }

  List<PaymentReminder> _mapRows(List<db.PaymentReminderRow> rows) {
    return rows.map(_mapper.mapRowToEntity).toList(growable: false);
  }

  void _validate(PaymentReminder reminder) {
    if (reminder.amount <= 0) {
      throw ArgumentError.value(
        reminder.amount,
        'amount',
        'Amount должен быть больше нуля',
      );
    }
    if (reminder.whenAtMs <= 0) {
      throw ArgumentError.value(
        reminder.whenAtMs,
        'whenAtMs',
        'whenAtMs должен быть положительным временем в мс',
      );
    }
  }
}
