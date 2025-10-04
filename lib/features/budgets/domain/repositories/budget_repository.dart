import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';

abstract class BudgetRepository {
  Stream<List<Budget>> watchBudgets();
  Future<List<Budget>> loadBudgets();
  Future<Budget?> findById(String id);
  Future<void> upsert(Budget budget);
  Future<void> softDelete(String id);

  Stream<List<BudgetInstance>> watchInstances(String budgetId);
  Future<List<BudgetInstance>> loadInstances(String budgetId);
  Future<void> upsertInstance(BudgetInstance instance);
  Future<void> deleteInstance(String id);
}
