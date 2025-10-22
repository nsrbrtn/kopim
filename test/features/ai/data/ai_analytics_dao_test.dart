import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/ai/data/local/ai_analytics_dao.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';

void main() {
  late db.AppDatabase database;
  late AiAnalyticsDao dao;

  setUpAll(() {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    database = db.AppDatabase.connect(
      drift.DatabaseConnection(NativeDatabase.memory()),
    );
    dao = AiAnalyticsDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertAccount({required String id}) {
    return database
        .into(database.accounts)
        .insert(
          db.AccountsCompanion(
            id: drift.Value<String>(id),
            name: const drift.Value<String>('Основной'),
            balance: const drift.Value<double>(0),
            currency: const drift.Value<String>('RUB'),
            type: const drift.Value<String>('checking'),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> insertCategory({required String id, required String name}) {
    return database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion(
            id: drift.Value<String>(id),
            name: drift.Value<String>(name),
            type: const drift.Value<String>('expense'),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> insertTransaction({
    required String id,
    required String accountId,
    String? categoryId,
    required double amount,
    required DateTime date,
  }) {
    return database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion(
            id: drift.Value<String>(id),
            accountId: drift.Value<String>(accountId),
            categoryId: drift.Value<String?>(categoryId),
            amount: drift.Value<double>(amount),
            date: drift.Value<DateTime>(date),
            type: const drift.Value<String>('expense'),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> insertBudget({
    required String id,
    required double amount,
    required DateTime periodStart,
    required DateTime periodEnd,
    List<String> categories = const <String>[],
    List<String> accounts = const <String>[],
    double spent = 0,
  }) async {
    await database
        .into(database.budgets)
        .insert(
          db.BudgetsCompanion(
            id: drift.Value<String>(id),
            title: const drift.Value<String>('Месячный бюджет'),
            period: const drift.Value<String>('monthly'),
            startDate: drift.Value<DateTime>(periodStart),
            endDate: drift.Value<DateTime?>(periodEnd),
            amount: drift.Value<double>(amount),
            scope: const drift.Value<String>('category'),
            categories: drift.Value<List<String>>(categories),
            accounts: drift.Value<List<String>>(accounts),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
    await database
        .into(database.budgetInstances)
        .insert(
          db.BudgetInstancesCompanion(
            id: drift.Value<String>('${id}_instance'),
            budgetId: drift.Value<String>(id),
            periodStart: drift.Value<DateTime>(periodStart),
            periodEnd: drift.Value<DateTime>(periodEnd),
            amount: drift.Value<double>(amount),
            spent: drift.Value<double>(spent),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  test(
    'watchMonthlyExpenses агрегирует расходы по месяцам и фильтру по счету',
    () async {
      await insertAccount(id: 'a1');
      await insertAccount(id: 'a2');
      await insertCategory(id: 'c1', name: 'Продукты');

      final Stream<List<MonthlyExpenseAggregate>> stream = dao
          .watchMonthlyExpenses(
            AiDataFilter(
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 12, 31),
              accountIds: <String>['a1'],
            ),
          );

      final Future<void> expectation = expectLater(
        stream,
        emitsInOrder(<dynamic>[
          isEmpty,
          predicate<List<MonthlyExpenseAggregate>>((
            List<MonthlyExpenseAggregate> values,
          ) {
            if (values.length != 1) return false;
            final MonthlyExpenseAggregate first = values.first;
            return first.totalExpense == 100 &&
                first.month.year == 2024 &&
                first.month.month == 2;
          }),
          predicate<List<MonthlyExpenseAggregate>>((
            List<MonthlyExpenseAggregate> values,
          ) {
            if (values.length != 1) return false;
            final MonthlyExpenseAggregate first = values.first;
            return first.totalExpense == 150 &&
                first.month.year == 2024 &&
                first.month.month == 2;
          }),
          predicate<List<MonthlyExpenseAggregate>>((
            List<MonthlyExpenseAggregate> values,
          ) {
            if (values.length != 1) return false;
            final MonthlyExpenseAggregate first = values.first;
            return first.totalExpense == 150 &&
                first.month.year == 2024 &&
                first.month.month == 2;
          }),
        ]),
      );

      await insertTransaction(
        id: 't1',
        accountId: 'a1',
        categoryId: 'c1',
        amount: 100,
        date: DateTime(2024, 2, 5),
      );
      await insertTransaction(
        id: 't2',
        accountId: 'a1',
        categoryId: 'c1',
        amount: 50,
        date: DateTime(2024, 2, 18),
      );
      await insertTransaction(
        id: 't3',
        accountId: 'a2',
        categoryId: 'c1',
        amount: 90,
        date: DateTime(2024, 2, 20),
      );

      await expectation;
    },
  );

  test('getTopCategories ограничивает выборку и учитывает фильтры', () async {
    await insertAccount(id: 'a1');
    await insertCategory(id: 'c1', name: 'Продукты');
    await insertCategory(id: 'c2', name: 'Транспорт');
    await insertCategory(id: 'c3', name: 'Разное');

    await insertTransaction(
      id: 't1',
      accountId: 'a1',
      categoryId: 'c1',
      amount: 120,
      date: DateTime(2024, 1, 10),
    );
    await insertTransaction(
      id: 't2',
      accountId: 'a1',
      categoryId: 'c2',
      amount: 80,
      date: DateTime(2024, 1, 11),
    );
    await insertTransaction(
      id: 't3',
      accountId: 'a1',
      categoryId: 'c3',
      amount: 40,
      date: DateTime(2024, 1, 12),
    );

    final List<CategoryExpenseAggregate> result = await dao.getTopCategories(
      AiDataFilter(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        accountIds: <String>['a1'],
        topCategoriesLimit: 2,
      ),
    );

    expect(result, hasLength(2));
    expect(result.first.displayName, 'Продукты');
    expect(result.first.totalExpense, 120);
    expect(result[1].displayName, 'Транспорт');
    expect(result[1].totalExpense, 80);
  });

  test('getBudgetForecasts возвращает экземпляры бюджета в периоде', () async {
    await insertBudget(
      id: 'b1',
      amount: 500,
      periodStart: DateTime(2024, 2, 1),
      periodEnd: DateTime(2024, 2, 29),
      accounts: const <String>['a1'],
      categories: const <String>['c1'],
      spent: 200,
    );

    final List<BudgetInstanceAggregate> result = await dao.getBudgetForecasts(
      AiDataFilter(
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 29),
      ),
    );

    expect(result, hasLength(1));
    final BudgetInstanceAggregate aggregate = result.first;
    expect(aggregate.budgetId, 'b1');
    expect(aggregate.allocated, 500);
    expect(aggregate.spent, 200);
    expect(aggregate.periodStart, DateTime(2024, 2, 1));
    expect(aggregate.periodEnd, DateTime(2024, 2, 29));
  });
}
