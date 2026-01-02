import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_card_repository.dart';

class GetCreditCardByAccountIdUseCase {
  GetCreditCardByAccountIdUseCase(this._repository);

  final CreditCardRepository _repository;

  Future<CreditCardEntity?> call(String accountId) {
    return _repository.getByAccountId(accountId);
  }
}
