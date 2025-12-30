import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';

class PaymentRemindersRepositoryImpl implements PaymentRemindersRepository {
  PaymentRemindersRepositoryImpl({
    required db.AppDatabase database,
    required PaymentRemindersDao dao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _dao = dao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final PaymentRemindersDao _dao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'payment_reminder';

  @override
  Future<void> upsert(PaymentReminder reminder) async {
    await _database.transaction(() async {
      await _dao.upsert(reminder);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: reminder.id,
        operation: OutboxOperation.upsert,
        payload: reminder.toJson(),
      );
    });
  }

  @override
  Future<void> delete(String id) async {
    await _database.transaction(() async {
      final PaymentReminder? existing = await _dao.getById(id);
      await _dao.delete(id);
      if (existing == null) return;
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: existing.toJson(),
      );
    });
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
