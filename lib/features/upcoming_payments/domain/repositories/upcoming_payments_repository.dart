import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

abstract class UpcomingPaymentsRepository {
  Future<void> upsert(UpcomingPayment payment);

  Future<void> delete(String id);

  Stream<List<UpcomingPayment>> watchAll();

  Future<UpcomingPayment?> getById(String id);

  Future<UpcomingPayment?> getByCategoryId(String categoryId);
}
