import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';

class PaymentRemindersRepositoryImpl implements PaymentRemindersRepository {
  PaymentRemindersRepositoryImpl({required PaymentRemindersDao dao})
    : _dao = dao;

  final PaymentRemindersDao _dao;

  @override
  Future<void> upsert(PaymentReminder reminder) {
    return _dao.upsert(reminder);
  }

  @override
  Future<void> delete(String id) {
    return _dao.delete(id);
  }

  @override
  Stream<List<PaymentReminder>> watchAll() {
    return _dao.watchAll();
  }

  @override
  Stream<List<PaymentReminder>> watchUpcoming({int? limit}) {
    return _dao.watchUpcoming(limit: limit);
  }

  @override
  Future<PaymentReminder?> getById(String id) {
    return _dao.getById(id);
  }
}
