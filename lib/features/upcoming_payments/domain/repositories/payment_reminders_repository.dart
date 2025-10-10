import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';

abstract class PaymentRemindersRepository {
  Future<void> upsert(PaymentReminder reminder);

  Future<void> delete(String id);

  Stream<List<PaymentReminder>> watchAll();

  Stream<List<PaymentReminder>> watchUpcoming({int? limit});

  Future<PaymentReminder?> getById(String id);
}
