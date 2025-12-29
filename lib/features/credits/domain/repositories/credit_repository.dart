import 'package:kopim/features/credits/domain/entities/credit_entity.dart';

abstract class CreditRepository {
  Future<List<CreditEntity>> getCredits();
  Stream<List<CreditEntity>> watchCredits();
  Future<CreditEntity?> getCreditByAccountId(String accountId);
  Future<CreditEntity?> getCreditByCategoryId(String categoryId);
  Future<void> addCredit(CreditEntity credit);
  Future<void> updateCredit(CreditEntity credit);
  Future<void> deleteCredit(String id);
}
