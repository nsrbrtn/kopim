import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  DeleteBudgetUseCase({required BudgetRepository repository})
    : _repository = repository;

  final BudgetRepository _repository;

  Future<void> call(String id) => _repository.softDelete(id);
}
