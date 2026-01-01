import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/repositories/debt_repository.dart';

class DeleteDebtUseCase {
  DeleteDebtUseCase(this._repository);

  final DebtRepository _repository;

  Future<void> call(DebtEntity debt) => _repository.deleteDebt(debt.id);
}
