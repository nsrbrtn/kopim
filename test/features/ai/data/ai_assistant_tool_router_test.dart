import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/ai/data/local/ai_assistant_tool_dao.dart';
import 'package:kopim/features/ai/data/local/ai_analytics_dao.dart';
import 'package:kopim/features/ai/data/tools/ai_assistant_tool_router.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';

void main() {
  late db.AppDatabase database;
  late AiAssistantToolDao toolDao;
  late AiAnalyticsDao analyticsDao;
  late AiAssistantToolRouter router;

  setUpAll(() {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    database = db.AppDatabase.connect(
      drift.DatabaseConnection(NativeDatabase.memory()),
    );
    toolDao = AiAssistantToolDao(database);
    analyticsDao = AiAnalyticsDao(database);
    router = AiAssistantToolRouter(
      toolDao: toolDao,
      analyticsDao: analyticsDao,
      loggerService: LoggerService(),
      nowProvider: () => DateTime(2024, 4, 10, 12, 0),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertAccount({
    required String id,
    String currency = 'RUB',
  }) {
    return database
        .into(database.accounts)
        .insert(
          db.AccountsCompanion(
            id: drift.Value<String>(id),
            name: drift.Value<String>('Счет $id'),
            balance: const drift.Value<double>(0),
            currency: drift.Value<String>(currency),
            type: const drift.Value<String>('checking'),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> insertCategory({
    required String id,
    required String name,
    String? parentId,
  }) {
    return database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion(
            id: drift.Value<String>(id),
            name: drift.Value<String>(name),
            type: const drift.Value<String>('expense'),
            parentId: drift.Value<String?>(parentId),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> insertTransaction({
    required String id,
    required String accountId,
    required String categoryId,
    required double amount,
    required DateTime date,
  }) {
    return database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion(
            id: drift.Value<String>(id),
            accountId: drift.Value<String>(accountId),
            categoryId: drift.Value<String>(categoryId),
            amount: drift.Value<double>(amount),
            date: drift.Value<DateTime>(date),
            type: const drift.Value<String>('expense'),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  Future<void> insertBudget({
    required String id,
    required String title,
    required DateTime startDate,
    DateTime? endDate,
    double amount = 1000,
    String scope = 'byCategory',
    List<String> categories = const <String>[],
    List<String> accounts = const <String>[],
    List<BudgetCategoryAllocation> allocations =
        const <BudgetCategoryAllocation>[],
  }) {
    return database.into(database.budgets).insert(
          db.BudgetsCompanion(
            id: drift.Value<String>(id),
            title: drift.Value<String>(title),
            period: drift.Value<String>(BudgetPeriod.monthly.storageValue),
            startDate: drift.Value<DateTime>(startDate),
            endDate: drift.Value<DateTime?>(endDate),
            amount: drift.Value<double>(amount),
            scope: drift.Value<String>(scope),
            categories: drift.Value<List<String>>(categories),
            accounts: drift.Value<List<String>>(accounts),
            categoryAllocations: drift.Value<List<Map<String, dynamic>>>(
              allocations
                  .map(
                    (BudgetCategoryAllocation allocation) =>
                        allocation.toJson(),
                  )
                  .toList(growable: false),
            ),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  test('get_spending_summary возвращает суммы по валютам', () async {
    await insertAccount(id: 'a1', currency: 'RUB');
    await insertCategory(id: 'c1', name: 'Такси');
    await insertTransaction(
      id: 't1',
      accountId: 'a1',
      categoryId: 'c1',
      amount: 120,
      date: DateTime(2024, 4, 8),
    );
    await insertTransaction(
      id: 't2',
      accountId: 'a1',
      categoryId: 'c1',
      amount: 80,
      date: DateTime(2024, 4, 9),
    );

    final AiToolCall toolCall = AiToolCall(
      id: 'call_1',
      name: 'get_spending_summary',
      arguments: jsonEncode(<String, Object?>{'period': 'last_30_days'}),
    );

    final AiAssistantToolExecutionResult result = await router
        .runToolCalls(<AiToolCall>[toolCall]);
    final String content = result.messages.single.content;
    final Map<String, dynamic> payload =
        jsonDecode(content) as Map<String, dynamic>;
    final List<Map<String, dynamic>> totals =
        (payload['totals'] as List<dynamic>)
            .map((dynamic item) => item as Map<String, dynamic>)
            .toList(growable: false);

    expect(payload['total_count'], 2);
    expect(totals.length, 1);
    final Map<String, dynamic> total = totals.first;
    expect(total['currency'], 'RUB');
    expect(total['total'], 200);
  });

  test('find_categories ищет по названию', () async {
    await insertCategory(id: 'c1', name: 'Такси');
    await insertCategory(id: 'c2', name: 'Еда');

    final AiToolCall toolCall = AiToolCall(
      id: 'call_2',
      name: 'find_categories',
      arguments: jsonEncode(<String, Object?>{'query': 'Так'}),
    );

    final AiAssistantToolExecutionResult result = await router
        .runToolCalls(<AiToolCall>[toolCall]);
    final Map<String, dynamic> payload =
        jsonDecode(result.messages.single.content) as Map<String, dynamic>;
    final List<Map<String, dynamic>> items =
        (payload['items'] as List<dynamic>)
            .map((dynamic item) => item as Map<String, dynamic>)
            .toList(growable: false);

    expect(items.length, 1);
    final Map<String, dynamic> item = items.first;
    expect(item['id'], 'c1');
    expect(item['name'], 'Такси');
  });

  test('get_spending_summary учитывает дочерние категории', () async {
    await insertAccount(id: 'a1', currency: 'RUB');
    await insertCategory(id: 'c_parent', name: 'Еда');
    await insertCategory(
      id: 'c_child',
      name: 'Кафе',
      parentId: 'c_parent',
    );
    await insertTransaction(
      id: 't1',
      accountId: 'a1',
      categoryId: 'c_child',
      amount: 150,
      date: DateTime(2024, 4, 9),
    );

    final AiToolCall toolCall = AiToolCall(
      id: 'call_3',
      name: 'get_spending_summary',
      arguments: jsonEncode(<String, Object?>{
        'period': 'last_30_days',
        'category_ids': <String>['c_parent'],
      }),
    );

    final AiAssistantToolExecutionResult result = await router
        .runToolCalls(<AiToolCall>[toolCall]);
    final Map<String, dynamic> payload =
        jsonDecode(result.messages.single.content) as Map<String, dynamic>;
    final List<Map<String, dynamic>> totals =
        (payload['totals'] as List<dynamic>)
            .map((dynamic item) => item as Map<String, dynamic>)
            .toList(growable: false);

    expect(payload['total_count'], 1);
    expect(totals.length, 1);
    expect(totals.first['total'], 150);
  });

  test('get_budgets возвращает прогресс и категории бюджета', () async {
    await insertAccount(id: 'a1', currency: 'RUB');
    await insertCategory(id: 'c1', name: 'Еда');
    await insertCategory(id: 'c2', name: 'Транспорт');
    await insertBudget(
      id: 'b1',
      title: 'Бюджет апреля',
      startDate: DateTime(2024, 4, 1),
      amount: 1000,
      scope: BudgetScope.byCategory.storageValue,
      categories: const <String>['c1', 'c2'],
      allocations: const <BudgetCategoryAllocation>[
        BudgetCategoryAllocation(categoryId: 'c1', limit: 600),
        BudgetCategoryAllocation(categoryId: 'c2', limit: 400),
      ],
    );
    await insertTransaction(
      id: 't1',
      accountId: 'a1',
      categoryId: 'c1',
      amount: 200,
      date: DateTime(2024, 4, 5),
    );
    await insertTransaction(
      id: 't2',
      accountId: 'a1',
      categoryId: 'c2',
      amount: 150,
      date: DateTime(2024, 4, 7),
    );

    final AiToolCall toolCall = AiToolCall(
      id: 'call_4',
      name: 'get_budgets',
      arguments: jsonEncode(<String, Object?>{'budget_id': 'b1'}),
    );

    final AiAssistantToolExecutionResult result = await router
        .runToolCalls(<AiToolCall>[toolCall]);
    final Map<String, dynamic> payload =
        jsonDecode(result.messages.single.content) as Map<String, dynamic>;
    final List<dynamic> items = payload['items'] as List<dynamic>;
    expect(items.length, 1);
    final Map<String, dynamic> budget = items.first as Map<String, dynamic>;
    expect(budget['id'], 'b1');
    expect(budget['spent'], 350);
    expect(budget['remaining'], 650);

    final List<dynamic> categories = budget['categories'] as List<dynamic>;
    final Map<String, dynamic> food = categories
        .cast<Map<String, dynamic>>()
        .firstWhere((Map<String, dynamic> item) => item['id'] == 'c1');
    final Map<String, dynamic> transport = categories
        .cast<Map<String, dynamic>>()
        .firstWhere((Map<String, dynamic> item) => item['id'] == 'c2');
    expect(food['spent'], 200);
    expect(food['limit'], 600);
    expect(food['remaining'], 400);
    expect(transport['spent'], 150);
    expect(transport['limit'], 400);
    expect(transport['remaining'], 250);
  });
}
