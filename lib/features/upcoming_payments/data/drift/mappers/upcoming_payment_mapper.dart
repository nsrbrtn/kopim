import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

class UpcomingPaymentMapper {
  const UpcomingPaymentMapper();

  UpcomingPayment mapRowToEntity(db.UpcomingPaymentRow row) {
    final int scale = row.amountScale;
    final BigInt amountMinor = BigInt.parse(row.amountMinor);
    final BigInt resolvedMinor = amountMinor == BigInt.zero && row.amount != 0
        ? Money.fromDouble(row.amount, currency: 'XXX', scale: scale).minor
        : amountMinor;
    return UpcomingPayment(
      id: row.id,
      title: row.title,
      accountId: row.accountId,
      categoryId: row.categoryId,
      amountMinor: resolvedMinor,
      amountScale: scale,
      dayOfMonth: row.dayOfMonth,
      notifyDaysBefore: row.notifyDaysBefore,
      notifyTimeHhmm: row.notifyTimeHhmm,
      note: row.note,
      autoPost: row.autoPost,
      isActive: row.isActive,
      nextRunAtMs: row.nextRunAt,
      nextNotifyAtMs: row.nextNotifyAt,
      createdAtMs: row.createdAt,
      updatedAtMs: row.updatedAt,
    );
  }

  db.UpcomingPaymentsCompanion mapEntityToCompanion(UpcomingPayment payment) {
    final MoneyAmount amount = payment.amountValue;
    return db.UpcomingPaymentsCompanion(
      id: Value<String>(payment.id),
      title: Value<String>(payment.title),
      accountId: Value<String>(payment.accountId),
      categoryId: Value<String>(payment.categoryId),
      amount: Value<double>(amount.toDouble()),
      amountMinor: Value<String>(amount.minor.toString()),
      amountScale: Value<int>(amount.scale),
      dayOfMonth: Value<int>(payment.dayOfMonth),
      notifyDaysBefore: Value<int>(payment.notifyDaysBefore),
      notifyTimeHhmm: Value<String>(payment.notifyTimeHhmm),
      note: Value<String?>(payment.note),
      autoPost: Value<bool>(payment.autoPost),
      isActive: Value<bool>(payment.isActive),
      nextRunAt: Value<int?>(payment.nextRunAtMs),
      nextNotifyAt: Value<int?>(payment.nextNotifyAtMs),
      createdAt: Value<int>(payment.createdAtMs),
      updatedAt: Value<int>(payment.updatedAtMs),
    );
  }
}
