import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/upcoming_payments/data/drift/mappers/upcoming_payment_mapper.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

class UpcomingPaymentsDao {
  UpcomingPaymentsDao(
    this._db, {
    UpcomingPaymentMapper mapper = const UpcomingPaymentMapper(),
  }) : _mapper = mapper;

  final db.AppDatabase _db;
  final UpcomingPaymentMapper _mapper;

  Stream<List<UpcomingPayment>> watchAll() {
    final SimpleSelectStatement<
      db.$UpcomingPaymentsTable,
      db.UpcomingPaymentRow
    >
    query = _db.select(_db.upcomingPayments)
      ..where((db.$UpcomingPaymentsTable tbl) => tbl.isActive.equals(true))
      ..orderBy(<OrderClauseGenerator<db.$UpcomingPaymentsTable>>[
        (db.$UpcomingPaymentsTable tbl) => OrderingTerm(
          expression: tbl.nextNotifyAt,
          mode: OrderingMode.asc,
          nulls: NullsOrder.last,
        ),
        (db.$UpcomingPaymentsTable tbl) => OrderingTerm(
          expression: tbl.nextRunAt,
          mode: OrderingMode.asc,
          nulls: NullsOrder.last,
        ),
        (db.$UpcomingPaymentsTable tbl) =>
            OrderingTerm(expression: tbl.dayOfMonth, mode: OrderingMode.asc),
        (db.$UpcomingPaymentsTable tbl) =>
            OrderingTerm(expression: tbl.title, mode: OrderingMode.asc),
      ]);
    return query.watch().map(_mapRows);
  }

  Future<List<UpcomingPayment>> getAll() async {
    final SimpleSelectStatement<
      db.$UpcomingPaymentsTable,
      db.UpcomingPaymentRow
    >
    query = _db.select(_db.upcomingPayments)
      ..orderBy(<OrderClauseGenerator<db.$UpcomingPaymentsTable>>[
        (db.$UpcomingPaymentsTable tbl) =>
            OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ]);
    final List<db.UpcomingPaymentRow> rows = await query.get();
    return rows.map(_mapper.mapRowToEntity).toList(growable: false);
  }

  Future<UpcomingPayment?> getById(String id) async {
    final SimpleSelectStatement<
      db.$UpcomingPaymentsTable,
      db.UpcomingPaymentRow
    >
    query = _db.select(_db.upcomingPayments)
      ..where((db.$UpcomingPaymentsTable tbl) => tbl.id.equals(id))
      ..limit(1);
    final db.UpcomingPaymentRow? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapper.mapRowToEntity(row);
  }

  Future<void> upsert(UpcomingPayment payment) async {
    _validate(payment);
    await _db
        .into(_db.upcomingPayments)
        .insertOnConflictUpdate(_mapper.mapEntityToCompanion(payment));
  }

  Future<void> delete(String id) {
    return (_db.delete(
      _db.upcomingPayments,
    )..where((db.$UpcomingPaymentsTable tbl) => tbl.id.equals(id))).go();
  }

  List<UpcomingPayment> _mapRows(List<db.UpcomingPaymentRow> rows) {
    return rows.map(_mapper.mapRowToEntity).toList(growable: false);
  }

  void _validate(UpcomingPayment payment) {
    if (payment.amountValue.minor <= BigInt.zero) {
      throw ArgumentError.value(
        payment.amountValue,
        'amount',
        'Amount должен быть больше нуля',
      );
    }
    if (payment.dayOfMonth < 1 || payment.dayOfMonth > 31) {
      throw ArgumentError.value(
        payment.dayOfMonth,
        'dayOfMonth',
        'День месяца должен быть в диапазоне 1..31',
      );
    }
    if (payment.notifyDaysBefore < 0) {
      throw ArgumentError.value(
        payment.notifyDaysBefore,
        'notifyDaysBefore',
        'Значение notifyDaysBefore не может быть отрицательным',
      );
    }
    if (!_isValidHhmm(payment.notifyTimeHhmm)) {
      throw ArgumentError.value(
        payment.notifyTimeHhmm,
        'notifyTimeHhmm',
        'Время уведомления должно быть в формате HH:mm',
      );
    }
  }

  bool _isValidHhmm(String value) {
    if (value.length != 5 || value[2] != ':') {
      return false;
    }
    final int? hour = int.tryParse(value.substring(0, 2));
    final int? minute = int.tryParse(value.substring(3, 5));
    if (hour == null || minute == null) {
      return false;
    }
    return hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
  }
}
