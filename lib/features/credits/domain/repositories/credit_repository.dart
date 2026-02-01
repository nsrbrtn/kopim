import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';

abstract class CreditRepository {
  Future<List<CreditEntity>> getCredits();
  Stream<List<CreditEntity>> watchCredits();
  Future<CreditEntity?> getCreditByAccountId(String accountId);
  Future<CreditEntity?> getCreditByCategoryId(String categoryId);
  Future<void> addCredit(CreditEntity credit);
  Future<void> updateCredit(CreditEntity credit);
  Future<void> deleteCredit(String id);

  // Payment Logic
  Future<void> addSchedule(List<CreditPaymentScheduleEntity> schedule);
  Future<List<CreditPaymentScheduleEntity>> getSchedule(String creditId);
  Stream<List<CreditPaymentScheduleEntity>> watchSchedule(String creditId);
  Future<void> updateScheduleItem(CreditPaymentScheduleEntity item);
  Future<void> addPaymentGroup(CreditPaymentGroupEntity group);
  Future<List<CreditPaymentGroupEntity>> getPaymentGroups(String creditId);
}
