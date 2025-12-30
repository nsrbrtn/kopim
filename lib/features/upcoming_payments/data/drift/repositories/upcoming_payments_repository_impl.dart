import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';

class UpcomingPaymentsRepositoryImpl implements UpcomingPaymentsRepository {
  UpcomingPaymentsRepositoryImpl({
    required db.AppDatabase database,
    required UpcomingPaymentsDao dao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _dao = dao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final UpcomingPaymentsDao _dao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'upcoming_payment';

  @override
  Future<void> upsert(UpcomingPayment payment) async {
    await _database.transaction(() async {
      await _dao.upsert(payment);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: payment.id,
        operation: OutboxOperation.upsert,
        payload: payment.toJson(),
      );
    });
  }

  @override
  Future<void> delete(String id) async {
    await _database.transaction(() async {
      final UpcomingPayment? existing = await _dao.getById(id);
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
  Stream<List<UpcomingPayment>> watchAll() {
    return _dao.watchAll();
  }

  @override
  Future<UpcomingPayment?> getById(String id) {
    return _dao.getById(id);
  }
}
