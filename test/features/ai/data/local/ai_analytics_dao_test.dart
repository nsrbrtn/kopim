import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/features/ai/data/local/ai_analytics_dao.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';

void main() {
  late AppDatabase db;
  late AiAnalyticsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = AiAnalyticsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('getMonthlyExpenses handles mixed date formats correctly', () async {
    // 1. Setup Data
    // We will insert data using custom statements to bypass Drift's type safety
    // and simulate "messy" data (Integers and Strings).

    // Expense 1: Standard INT timestamp (Dec 15, 2025 UTC)
    // 1765756800 = 2025-12-15 00:00:00 UTC
    await db.customStatement(
      'INSERT INTO accounts (id, name, balance, currency, type) VALUES (?, ?, ?, ?, ?)',
      <Object?>['acc1', 'Cash', 1000, 'USD', 'cash'],
    );
    await db.customStatement(
      'INSERT INTO categories (id, name, type) VALUES (?, ?, ?)',
      <Object?>['cat1', 'Food', 'expense'],
    );

    // Case 1: Integer Date in Range (Dec 15 2025)
    await db.customStatement(
      'INSERT INTO transactions (id, account_id, category_id, amount, date, type) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>['tx1', 'acc1', 'cat1', 100.0, 1765756800, 'expense'],
    );

    // Case 2: String Date in Range (Dec 20 2025)
    // ISO String format without T, typical for SQLite datetime output, or with T
    await db.customStatement(
      'INSERT INTO transactions (id, account_id, category_id, amount, date, type) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>['tx2', 'acc1', 'cat1', 200.0, '2025-12-20 10:00:00', 'expense'],
    );

    // Case 3: Integer Date OUT of Range (Nov 15 2025)
    // 1763164800 = 2025-11-15
    await db.customStatement(
      'INSERT INTO transactions (id, account_id, category_id, amount, date, type) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>['tx3', 'acc1', 'cat1', 50.0, 1763164800, 'expense'],
    );

    // Case 4: String Date OUT of Range (Jan 15 2026)
    await db.customStatement(
      'INSERT INTO transactions (id, account_id, category_id, amount, date, type) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>['tx4', 'acc1', 'cat1', 50.0, '2026-01-15 10:00:00', 'expense'],
    );

    // 2. Define Filter for Dec 2025
    // Local: Dec 1 to Dec 31
    final AiDataFilter filter = AiDataFilter(
      startDate: DateTime(2025, 12, 1),
      endDate: DateTime(2025, 12, 31, 23, 59, 59),
      topCategoriesLimit: 5,
    );

    // 3. Execute
    final List<MonthlyExpenseAggregate> results = await dao.getMonthlyExpenses(
      filter,
    );

    // 4. Verify
    // Should have 1 entry for 2025-12
    // Total should be 100 + 200 = 300.
    // Ignored: 50 (Nov), 50 (Jan).

    expect(results.length, 1, reason: 'Should return exactly one month');
    final MonthlyExpenseAggregate december = results.first;
    expect(december.month, DateTime(2025, 12, 1));
    expect(
      december.totalExpense,
      300.0,
      reason: 'Should sum both INT and STRING date transactions',
    );

    // Also verify Top Categories
    final List<CategoryExpenseAggregate> categories = await dao
        .getTopCategories(filter);
    expect(categories.length, 1);
    expect(categories.first.totalExpense, 300.0);
  });
}
