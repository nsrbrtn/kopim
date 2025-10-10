import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

class UpcomingPaymentMapper {
  const UpcomingPaymentMapper();

  UpcomingPayment mapRowToEntity(db.UpcomingPaymentRow row) {
    return UpcomingPayment(
      id: row.id,
      title: row.title,
      accountId: row.accountId,
      categoryId: row.categoryId,
      amount: row.amount,
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
    return db.UpcomingPaymentsCompanion(
      id: Value<String>(payment.id),
      title: Value<String>(payment.title),
      accountId: Value<String>(payment.accountId),
      categoryId: Value<String>(payment.categoryId),
      amount: Value<double>(payment.amount),
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
