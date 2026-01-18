import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';

class PaymentReminderMapper {
  const PaymentReminderMapper();

  PaymentReminder mapRowToEntity(db.PaymentReminderRow row) {
    return PaymentReminder(
      id: row.id,
      title: row.title,
      amount: row.amount,
      amountMinor: BigInt.parse(row.amountMinor),
      amountScale: row.amountScale,
      whenAtMs: row.whenAt,
      note: row.note,
      isDone: row.isDone,
      lastNotifiedAtMs: row.lastNotifiedAt,
      createdAtMs: row.createdAt,
      updatedAtMs: row.updatedAt,
    );
  }

  db.PaymentRemindersCompanion mapEntityToCompanion(PaymentReminder reminder) {
    final int scale = (reminder.amountScale ?? 0) > 0
        ? reminder.amountScale!
        : 2;
    final BigInt amountMinor = reminder.amountMinor ??
        Money.fromDouble(
          reminder.amount,
          currency: 'XXX',
          scale: scale,
        ).minor;
    return db.PaymentRemindersCompanion(
      id: Value<String>(reminder.id),
      title: Value<String>(reminder.title),
      amount: Value<double>(reminder.amount),
      amountMinor: Value<String>(amountMinor.toString()),
      amountScale: Value<int>(scale),
      whenAt: Value<int>(reminder.whenAtMs),
      note: Value<String?>(reminder.note),
      isDone: Value<bool>(reminder.isDone),
      lastNotifiedAt: Value<int?>(reminder.lastNotifiedAtMs),
      createdAt: Value<int>(reminder.createdAtMs),
      updatedAt: Value<int>(reminder.updatedAtMs),
    );
  }
}
