import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';

class SaveBudgetUseCase {
  SaveBudgetUseCase({required BudgetRepository repository})
    : _repository = repository;

  final BudgetRepository _repository;

  Future<void> call(Budget budget) => _repository.upsert(budget);
}
