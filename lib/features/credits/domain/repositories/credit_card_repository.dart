import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';

abstract class CreditCardRepository {
  Stream<List<CreditCardEntity>> watchCreditCards();
  Future<List<CreditCardEntity>> getCreditCards();
  Future<CreditCardEntity?> getByAccountId(String accountId);
  Future<void> addCreditCard(CreditCardEntity creditCard);
  Future<void> updateCreditCard(CreditCardEntity creditCard);
  Future<void> deleteCreditCard(String id);
}
