import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';

class BudgetDao {
  BudgetDao(this._db);

  final db.AppDatabase _db;

  Stream<List<Budget>> watchActiveBudgets() {
    final SimpleSelectStatement<db.$BudgetsTable, db.BudgetRow> query =
        _db.select(_db.budgets)
          ..where((db.$BudgetsTable tbl) => tbl.isDeleted.equals(false))
          ..orderBy(<OrderClauseGenerator<db.$BudgetsTable>>[
            (db.$BudgetsTable tbl) => OrderingTerm(
              expression: tbl.createdAt,
              mode: OrderingMode.desc,
            ),
          ]);
    return query.watch().map(
      (List<db.BudgetRow> rows) =>
          rows.map(_mapBudgetRow).toList(growable: false),
    );
  }

  Future<List<Budget>> getActiveBudgets() async {
    final SimpleSelectStatement<db.$BudgetsTable, db.BudgetRow> query =
        _db.select(_db.budgets)
          ..where((db.$BudgetsTable tbl) => tbl.isDeleted.equals(false))
          ..orderBy(<OrderClauseGenerator<db.$BudgetsTable>>[
            (db.$BudgetsTable tbl) => OrderingTerm(
              expression: tbl.createdAt,
              mode: OrderingMode.desc,
            ),
          ]);
    final List<db.BudgetRow> rows = await query.get();
    return rows.map(_mapBudgetRow).toList(growable: false);
  }

  Future<Budget?> findById(String id) async {
    final SimpleSelectStatement<db.$BudgetsTable, db.BudgetRow> query =
        _db.select(_db.budgets)
          ..where((db.$BudgetsTable tbl) => tbl.id.equals(id));
    final db.BudgetRow? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapBudgetRow(row);
  }

  Future<List<Budget>> getAllBudgets() async {
    final List<db.BudgetRow> rows = await _db.select(_db.budgets).get();
    return rows.map(_mapBudgetRow).toList(growable: false);
  }

  Future<void> upsert(Budget budget) {
    return _db
        .into(_db.budgets)
        .insertOnConflictUpdate(_mapBudgetToCompanion(budget));
  }

  Future<void> upsertAll(List<Budget> budgets) async {
    if (budgets.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.budgets,
          budgets.map(_mapBudgetToCompanion).toList(growable: false),
        );
      });
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) {
    return (_db.update(
      _db.budgets,
    )..where((db.$BudgetsTable tbl) => tbl.id.equals(id))).write(
      db.BudgetsCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.BudgetsCompanion _mapBudgetToCompanion(Budget budget) {
    final int scale = (budget.amountScale ?? 0) > 0
        ? budget.amountScale!
        : 2;
    final BigInt amountMinor = budget.amountMinor ??
        Money.fromDouble(
          budget.amount,
          currency: 'XXX',
          scale: scale,
        ).minor;
    return db.BudgetsCompanion(
      id: Value<String>(budget.id),
      title: Value<String>(budget.title),
      period: Value<String>(budget.period.storageValue),
      startDate: Value<DateTime>(budget.startDate),
      endDate: Value<DateTime?>(budget.endDate),
      amount: Value<double>(budget.amount),
      amountMinor: Value<String>(amountMinor.toString()),
      amountScale: Value<int>(scale),
      scope: Value<String>(budget.scope.storageValue),
      categories: Value<List<String>>(budget.categories),
      accounts: Value<List<String>>(budget.accounts),
      categoryAllocations: Value<List<Map<String, dynamic>>>(
        budget.categoryAllocations
            .map((BudgetCategoryAllocation allocation) => allocation.toJson())
            .toList(growable: false),
      ),
      createdAt: Value<DateTime>(budget.createdAt),
      updatedAt: Value<DateTime>(budget.updatedAt),
      isDeleted: Value<bool>(budget.isDeleted),
    );
  }

  Budget _mapBudgetRow(db.BudgetRow row) {
    return Budget(
      id: row.id,
      title: row.title,
      period: BudgetPeriodX.fromStorage(row.period),
      startDate: row.startDate,
      endDate: row.endDate,
      amount: row.amount,
      amountMinor: BigInt.parse(row.amountMinor),
      amountScale: row.amountScale,
      scope: BudgetScopeX.fromStorage(row.scope),
      categories: row.categories,
      accounts: row.accounts,
      categoryAllocations: row.categoryAllocations
          .map(
            (Map<String, dynamic> json) =>
                BudgetCategoryAllocation.fromJson(json),
          )
          .toList(growable: false),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}

class BudgetInstanceDao {
  BudgetInstanceDao(this._db);

  final db.AppDatabase _db;

  Stream<List<BudgetInstance>> watchByBudgetId(String budgetId) {
    final SimpleSelectStatement<db.$BudgetInstancesTable, db.BudgetInstanceRow>
    query = _db.select(_db.budgetInstances)
      ..where((db.$BudgetInstancesTable tbl) => tbl.budgetId.equals(budgetId))
      ..orderBy(<OrderClauseGenerator<db.$BudgetInstancesTable>>[
        (db.$BudgetInstancesTable tbl) =>
            OrderingTerm(expression: tbl.periodStart, mode: OrderingMode.asc),
      ]);
    return query.watch().map(
      (List<db.BudgetInstanceRow> rows) =>
          rows.map(_mapInstanceRow).toList(growable: false),
    );
  }

  Future<List<BudgetInstance>> getByBudgetId(String budgetId) async {
    final SimpleSelectStatement<db.$BudgetInstancesTable, db.BudgetInstanceRow>
    query = _db.select(_db.budgetInstances)
      ..where((db.$BudgetInstancesTable tbl) => tbl.budgetId.equals(budgetId))
      ..orderBy(<OrderClauseGenerator<db.$BudgetInstancesTable>>[
        (db.$BudgetInstancesTable tbl) =>
            OrderingTerm(expression: tbl.periodStart, mode: OrderingMode.asc),
      ]);
    final List<db.BudgetInstanceRow> rows = await query.get();
    return rows.map(_mapInstanceRow).toList(growable: false);
  }

  Future<BudgetInstance?> findById(String id) async {
    final SimpleSelectStatement<db.$BudgetInstancesTable, db.BudgetInstanceRow>
    query = _db.select(_db.budgetInstances)
      ..where((db.$BudgetInstancesTable tbl) => tbl.id.equals(id));
    final db.BudgetInstanceRow? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapInstanceRow(row);
  }

  Future<List<BudgetInstance>> getAllInstances() async {
    final List<db.BudgetInstanceRow> rows = await _db
        .select(_db.budgetInstances)
        .get();
    return rows.map(_mapInstanceRow).toList(growable: false);
  }

  Future<void> upsert(BudgetInstance instance) {
    return _db
        .into(_db.budgetInstances)
        .insertOnConflictUpdate(_mapInstanceToCompanion(instance));
  }

  Future<void> upsertAll(List<BudgetInstance> instances) async {
    if (instances.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.budgetInstances,
          instances.map(_mapInstanceToCompanion).toList(growable: false),
        );
      });
    });
  }

  Future<void> deleteById(String id) {
    return (_db.delete(
      _db.budgetInstances,
    )..where((db.$BudgetInstancesTable tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteByBudgetId(String budgetId) {
    return (_db.delete(_db.budgetInstances)..where(
          (db.$BudgetInstancesTable tbl) => tbl.budgetId.equals(budgetId),
        ))
        .go();
  }

  db.BudgetInstancesCompanion _mapInstanceToCompanion(BudgetInstance instance) {
    final int scale = (instance.amountScale ?? 0) > 0
        ? instance.amountScale!
        : 2;
    final BigInt amountMinor = instance.amountMinor ??
        Money.fromDouble(
          instance.amount,
          currency: 'XXX',
          scale: scale,
        ).minor;
    final BigInt spentMinor = instance.spentMinor ??
        Money.fromDouble(
          instance.spent,
          currency: 'XXX',
          scale: scale,
        ).minor;
    return db.BudgetInstancesCompanion(
      id: Value<String>(instance.id),
      budgetId: Value<String>(instance.budgetId),
      periodStart: Value<DateTime>(instance.periodStart),
      periodEnd: Value<DateTime>(instance.periodEnd),
      amount: Value<double>(instance.amount),
      amountMinor: Value<String>(amountMinor.toString()),
      spent: Value<double>(instance.spent),
      spentMinor: Value<String>(spentMinor.toString()),
      amountScale: Value<int>(scale),
      status: Value<String>(instance.status.storageValue),
      createdAt: Value<DateTime>(instance.createdAt),
      updatedAt: Value<DateTime>(instance.updatedAt),
    );
  }

  BudgetInstance _mapInstanceRow(db.BudgetInstanceRow row) {
    return BudgetInstance(
      id: row.id,
      budgetId: row.budgetId,
      periodStart: row.periodStart,
      periodEnd: row.periodEnd,
      amount: row.amount,
      spent: row.spent,
      amountMinor: BigInt.parse(row.amountMinor),
      spentMinor: BigInt.parse(row.spentMinor),
      amountScale: row.amountScale,
      status: BudgetInstanceStatusX.fromStorage(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
