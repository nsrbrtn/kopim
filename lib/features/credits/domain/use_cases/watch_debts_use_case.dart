import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/repositories/debt_repository.dart';

class WatchDebtsUseCase {
  WatchDebtsUseCase(this._repository);

  final DebtRepository _repository;

  Stream<List<DebtEntity>> call() => _repository.watchDebts();
}
