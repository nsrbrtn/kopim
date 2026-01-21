import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';

class PaymentReminderMapper {
  const PaymentReminderMapper();

  PaymentReminder mapRowToEntity(db.PaymentReminderRow row) {
    final int scale = row.amountScale;
    final BigInt amountMinor = BigInt.parse(row.amountMinor);
    final BigInt resolvedMinor = amountMinor == BigInt.zero && row.amount != 0
        ? Money.fromDouble(row.amount, currency: 'XXX', scale: scale).minor
        : amountMinor;
    return PaymentReminder(
      id: row.id,
      title: row.title,
      amountMinor: resolvedMinor,
      amountScale: scale,
      whenAtMs: row.whenAt,
      note: row.note,
      isDone: row.isDone,
      lastNotifiedAtMs: row.lastNotifiedAt,
      createdAtMs: row.createdAt,
      updatedAtMs: row.updatedAt,
    );
  }

  db.PaymentRemindersCompanion mapEntityToCompanion(PaymentReminder reminder) {
    final MoneyAmount amount = reminder.amountValue;
    return db.PaymentRemindersCompanion(
      id: Value<String>(reminder.id),
      title: Value<String>(reminder.title),
      amount: Value<double>(amount.toDouble()),
      amountMinor: Value<String>(amount.minor.toString()),
      amountScale: Value<int>(amount.scale),
      whenAt: Value<int>(reminder.whenAtMs),
      note: Value<String?>(reminder.note),
      isDone: Value<bool>(reminder.isDone),
      lastNotifiedAt: Value<int?>(reminder.lastNotifiedAtMs),
      createdAt: Value<int>(reminder.createdAtMs),
      updatedAt: Value<int>(reminder.updatedAtMs),
    );
  }
}
