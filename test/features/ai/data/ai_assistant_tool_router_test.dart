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
  }) {
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
    final List<dynamic> totals = payload['totals'] as List<dynamic>;

    expect(payload['total_count'], 2);
    expect(totals.length, 1);
    expect(totals.first['currency'], 'RUB');
    expect(totals.first['total'], 200);
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
    final List<dynamic> items = payload['items'] as List<dynamic>;

    expect(items.length, 1);
    expect(items.first['id'], 'c1');
    expect(items.first['name'], 'Такси');
  });
}
