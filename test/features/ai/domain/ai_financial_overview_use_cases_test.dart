import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/ai/data/local/ai_analytics_dao.dart';
import 'package:kopim/features/ai/data/repositories/ai_financial_data_repository_impl.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/ai/domain/use_cases/get_ai_financial_overview_use_case.dart';
import 'package:kopim/features/ai/domain/use_cases/watch_ai_financial_overview_use_case.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';

void main() {
  late db.AppDatabase database;
  late AiAnalyticsDao dao;
  late AiFinancialDataRepositoryImpl repository;
  late GetAiFinancialOverviewUseCase getUseCase;
  late WatchAiFinancialOverviewUseCase watchUseCase;
  final DateTime fixedNow = DateTime(2024, 2, 15);

  setUpAll(() {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    database = db.AppDatabase.connect(
      drift.DatabaseConnection(NativeDatabase.memory()),
    );
    dao = AiAnalyticsDao(database);
    repository = AiFinancialDataRepositoryImpl(
      analyticsDao: dao,
      budgetSchedule: const BudgetSchedule(),
      nowProvider: () => fixedNow,
    );
    getUseCase = GetAiFinancialOverviewUseCase(repository);
    watchUseCase = WatchAiFinancialOverviewUseCase(repository);
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
            balanceMinor: const drift.Value<String>('0'),
            currency: const drift.Value<String>('RUB'),
            currencyScale: const drift.Value<int>(2),
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

  Future<void> insertIncomeCategory({
    required String id,
    required String name,
  }) {
    return database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion(
            id: drift.Value<String>(id),
            name: drift.Value<String>(name),
            type: const drift.Value<String>('income'),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> insertTransaction({
    required String id,
    required String accountId,
    String? categoryId,
    required MoneyAmount amount,
    required DateTime date,
    String type = 'expense',
  }) {
    return database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion(
            id: drift.Value<String>(id),
            accountId: drift.Value<String>(accountId),
            categoryId: drift.Value<String?>(categoryId),
            amount: drift.Value<double>(amount.toDouble()),
            amountMinor: drift.Value<String>(amount.minor.toString()),
            amountScale: drift.Value<int>(amount.scale),
            date: drift.Value<DateTime>(date),
            type: drift.Value<String>(type),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> insertBudget({
    required String id,
    required MoneyAmount amount,
    required DateTime periodStart,
    required DateTime periodEnd,
    List<String> categories = const <String>[],
    List<String> accounts = const <String>[],
    MoneyAmount? spent,
  }) async {
    final MoneyAmount resolvedSpent =
        spent ?? MoneyAmount(minor: BigInt.zero, scale: 2);
    await database
        .into(database.budgets)
        .insert(
          db.BudgetsCompanion(
            id: drift.Value<String>(id),
            title: const drift.Value<String>('Месячный бюджет'),
            period: const drift.Value<String>('monthly'),
            startDate: drift.Value<DateTime>(periodStart),
            endDate: drift.Value<DateTime?>(periodEnd),
            amount: drift.Value<double>(amount.toDouble()),
            amountMinor: drift.Value<String>(amount.minor.toString()),
            amountScale: drift.Value<int>(amount.scale),
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
            amount: drift.Value<double>(amount.toDouble()),
            spent: drift.Value<double>(resolvedSpent.toDouble()),
            amountMinor: drift.Value<String>(amount.minor.toString()),
            spentMinor: drift.Value<String>(resolvedSpent.minor.toString()),
            amountScale: drift.Value<int>(amount.scale),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> seedBaseData() async {
    await insertAccount(id: 'a1');
    await insertCategory(id: 'c1', name: 'Продукты');
    await insertIncomeCategory(id: 'c2', name: 'Зарплата');
    await insertBudget(
      id: 'b1',
      amount: MoneyAmount(minor: BigInt.from(50000), scale: 2),
      periodStart: DateTime(2024, 2, 1),
      periodEnd: DateTime(2024, 2, 29),
      accounts: const <String>['a1'],
      categories: const <String>['c1'],
      spent: MoneyAmount(minor: BigInt.from(20000), scale: 2),
    );
    await insertTransaction(
      id: 't1',
      accountId: 'a1',
      categoryId: 'c1',
      amount: MoneyAmount(minor: BigInt.from(20000), scale: 2),
      date: DateTime(2024, 2, 5),
    );
    await insertTransaction(
      id: 't_income_1',
      accountId: 'a1',
      categoryId: 'c2',
      amount: MoneyAmount(minor: BigInt.from(120000), scale: 2),
      date: DateTime(2024, 2, 3),
      type: 'income',
    );
  }

  test(
    'GetAiFinancialOverviewUseCase возвращает агрегированный снимок',
    () async {
      await seedBaseData();

      final AiFinancialOverview overview = await getUseCase.execute(
        filter: AiDataFilter(
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 2, 29),
          accountIds: <String>['a1'],
        ),
      );

      expect(overview.monthlyExpenses, hasLength(1));
      expect(
        overview.monthlyExpenses.first.totalExpense,
        MoneyAmount(minor: BigInt.from(20000), scale: 2),
      );
      expect(overview.monthlyIncomes, hasLength(1));
      expect(
        overview.monthlyIncomes.first.totalIncome,
        MoneyAmount(minor: BigInt.from(120000), scale: 2),
      );
      expect(overview.topCategories, hasLength(1));
      expect(overview.topCategories.first.displayName, 'Продукты');
      expect(
        overview.topCategories.first.totalExpense,
        MoneyAmount(minor: BigInt.from(20000), scale: 2),
      );
      expect(overview.topIncomeCategories, hasLength(1));
      expect(overview.topIncomeCategories.first.displayName, 'Зарплата');
      expect(
        overview.topIncomeCategories.first.totalIncome,
        MoneyAmount(minor: BigInt.from(120000), scale: 2),
      );
      expect(overview.budgetForecasts, hasLength(1));
      final BudgetForecastInsight forecast = overview.budgetForecasts.first;
      expect(
        forecast.allocated,
        MoneyAmount(minor: BigInt.from(50000), scale: 2),
      );
      expect(forecast.spent, MoneyAmount(minor: BigInt.from(20000), scale: 2));
      expect(forecast.status, BudgetForecastStatus.onTrack);
      expect(overview.generatedAt, fixedNow);
    },
  );

  test(
    'WatchAiFinancialOverviewUseCase реагирует на новые транзакции',
    () async {
      await seedBaseData();

      final Stream<AiFinancialOverview> stream = watchUseCase
          .execute(
            filter: AiDataFilter(
              startDate: DateTime(2024, 2, 1),
              endDate: DateTime(2024, 2, 29),
              accountIds: <String>['a1'],
            ),
          )
          .asBroadcastStream();

      final AiFinancialOverview initial = await stream.first;
      expect(
        initial.monthlyExpenses.single.totalExpense,
        MoneyAmount(minor: BigInt.from(20000), scale: 2),
      );
      expect(
        initial.monthlyIncomes.single.totalIncome,
        MoneyAmount(minor: BigInt.from(120000), scale: 2),
      );
      expect(
        initial.topCategories.single.totalExpense,
        MoneyAmount(minor: BigInt.from(20000), scale: 2),
      );
      expect(
        initial.topIncomeCategories.single.totalIncome,
        MoneyAmount(minor: BigInt.from(120000), scale: 2),
      );

      await insertTransaction(
        id: 't2',
        accountId: 'a1',
        categoryId: 'c1',
        amount: MoneyAmount(minor: BigInt.from(6000), scale: 2),
        date: DateTime(2024, 2, 12),
      );

      final AiFinancialOverview updated = await stream.skip(1).first;
      expect(
        updated.monthlyExpenses.single.totalExpense,
        MoneyAmount(minor: BigInt.from(26000), scale: 2),
      );
      expect(
        updated.monthlyIncomes.single.totalIncome,
        MoneyAmount(minor: BigInt.from(120000), scale: 2),
      );
      expect(
        updated.topCategories.single.totalExpense,
        MoneyAmount(minor: BigInt.from(26000), scale: 2),
      );
      expect(
        updated.topIncomeCategories.single.totalIncome,
        MoneyAmount(minor: BigInt.from(120000), scale: 2),
      );
    },
  );
}
