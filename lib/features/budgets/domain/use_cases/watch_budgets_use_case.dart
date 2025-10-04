import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';

class WatchBudgetsUseCase {
  WatchBudgetsUseCase({required BudgetRepository repository})
    : _repository = repository;

  final BudgetRepository _repository;

  Stream<List<Budget>> call() => _repository.watchBudgets();
}
