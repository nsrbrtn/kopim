import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_card_repository.dart';

class UpdateCreditCardUseCase {
  UpdateCreditCardUseCase(this._repository);

  final CreditCardRepository _repository;

  Future<void> call(CreditCardEntity creditCard) {
    return _repository.updateCreditCard(creditCard);
  }
}
