import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';

class PaymentReminderMapper {
  const PaymentReminderMapper();

  PaymentReminder mapRowToEntity(db.PaymentReminderRow row) {
    return PaymentReminder(
      id: row.id,
      title: row.title,
      amount: row.amount,
      whenAtMs: row.whenAt,
      note: row.note,
      isDone: row.isDone,
      lastNotifiedAtMs: row.lastNotifiedAt,
      createdAtMs: row.createdAt,
      updatedAtMs: row.updatedAt,
    );
  }

  db.PaymentRemindersCompanion mapEntityToCompanion(PaymentReminder reminder) {
    return db.PaymentRemindersCompanion(
      id: Value<String>(reminder.id),
      title: Value<String>(reminder.title),
      amount: Value<double>(reminder.amount),
      whenAt: Value<int>(reminder.whenAtMs),
      note: Value<String?>(reminder.note),
      isDone: Value<bool>(reminder.isDone),
      lastNotifiedAt: Value<int?>(reminder.lastNotifiedAtMs),
      createdAt: Value<int>(reminder.createdAtMs),
      updatedAt: Value<int>(reminder.updatedAtMs),
    );
  }
}
