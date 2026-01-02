import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_card_repository.dart';

class WatchCreditCardsUseCase {
  WatchCreditCardsUseCase(this._repository);

  final CreditCardRepository _repository;

  Stream<List<CreditCardEntity>> call() => _repository.watchCreditCards();
}
