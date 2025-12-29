import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';

class WatchCreditsUseCase {
  WatchCreditsUseCase(this._repository);
  final CreditRepository _repository;

  Stream<List<CreditEntity>> call() => _repository.watchCredits();
}
