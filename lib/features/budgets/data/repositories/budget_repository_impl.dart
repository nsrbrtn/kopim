import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required db.AppDatabase database,
    required BudgetDao budgetDao,
    required BudgetInstanceDao budgetInstanceDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _budgetDao = budgetDao,
       _budgetInstanceDao = budgetInstanceDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final BudgetDao _budgetDao;
  final BudgetInstanceDao _budgetInstanceDao;
  final OutboxDao _outboxDao;

  static const String _budgetEntityType = 'budget';
  static const String _instanceEntityType = 'budget_instance';

  @override
  Stream<List<Budget>> watchBudgets() {
    return _budgetDao.watchActiveBudgets();
  }

  @override
  Future<List<Budget>> loadBudgets() async {
    return _budgetDao.getActiveBudgets();
  }

  @override
  Future<Budget?> findById(String id) async {
    return _budgetDao.findById(id);
  }

  @override
  Future<void> upsert(Budget budget) async {
    final DateTime now = DateTime.now();
    final Budget toPersist = budget.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _budgetDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _budgetEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapBudgetPayload(toPersist),
      );
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _budgetDao.markDeleted(id, now);
      final Budget? budget = await _budgetDao.findById(id);
      if (budget == null) {
        return;
      }
      final Budget removed = budget.copyWith(isDeleted: true, updatedAt: now);
      await _outboxDao.enqueue(
        entityType: _budgetEntityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: _mapBudgetPayload(removed),
      );
      await _budgetInstanceDao.deleteByBudgetId(id);
    });
  }

  @override
  Stream<List<BudgetInstance>> watchInstances(String budgetId) {
    return _budgetInstanceDao.watchByBudgetId(budgetId);
  }

  @override
  Future<List<BudgetInstance>> loadInstances(String budgetId) async {
    return _budgetInstanceDao.getByBudgetId(budgetId);
  }

  @override
  Future<void> upsertInstance(BudgetInstance instance) async {
    final DateTime now = DateTime.now();
    final BudgetInstance toPersist = instance.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _budgetInstanceDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _instanceEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapInstancePayload(toPersist),
      );
    });
  }

  @override
  Future<void> deleteInstance(String id) async {
    final BudgetInstance? instance = await _budgetInstanceDao.findById(id);
    if (instance == null) {
      return;
    }
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _budgetInstanceDao.deleteById(id);
      await _outboxDao.enqueue(
        entityType: _instanceEntityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: _mapInstancePayload(instance.copyWith(updatedAt: now)),
      );
    });
  }

  Map<String, dynamic> _mapBudgetPayload(Budget budget) {
    final Map<String, dynamic> json = budget.toJson();
    json['startDate'] = budget.startDate.toIso8601String();
    json['endDate'] = budget.endDate?.toIso8601String();
    json['createdAt'] = budget.createdAt.toIso8601String();
    json['updatedAt'] = budget.updatedAt.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapInstancePayload(BudgetInstance instance) {
    final Map<String, dynamic> json = instance.toJson();
    json['periodStart'] = instance.periodStart.toIso8601String();
    json['periodEnd'] = instance.periodEnd.toIso8601String();
    json['createdAt'] = instance.createdAt.toIso8601String();
    json['updatedAt'] = instance.updatedAt.toIso8601String();
    return json;
  }
}
