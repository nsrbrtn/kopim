import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';

class UpcomingPaymentsRepositoryImpl implements UpcomingPaymentsRepository {
  UpcomingPaymentsRepositoryImpl({required UpcomingPaymentsDao dao})
    : _dao = dao;

  final UpcomingPaymentsDao _dao;

  @override
  Future<void> upsert(UpcomingPayment payment) {
    return _dao.upsert(payment);
  }

  @override
  Future<void> delete(String id) {
    return _dao.delete(id);
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
