import 'package:kopim/features/credits/domain/repositories/credit_card_repository.dart';

class DeleteCreditCardUseCase {
  DeleteCreditCardUseCase(this._repository);

  final CreditCardRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteCreditCard(id);
  }
}
