import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/sync_data_sanitizer.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late MockLoggerService logger;
  late SyncDataSanitizer sanitizer;

  setUp(() {
    logger = MockLoggerService();
    sanitizer = SyncDataSanitizer(logger: logger);
  });

  group('SyncDataSanitizer - Transactions', () {
    test('Should keep valid transactions', () {
      final TransactionEntity tx = _createTx(
        id: '1',
        accountId: 'acc1',
        categoryId: 'cat1',
        savingGoalId: 'goal1',
      );
      final List<TransactionEntity> result = sanitizer.sanitizeTransactions(
        transactions: <TransactionEntity>[tx],
        validAccountIds: <String>{'acc1'},
        validCategoryIds: <String>{'cat1'},
        validSavingGoalIds: <String>{'goal1'},
      );

      expect(result.length, 1);
      expect(result.first, tx);
      verifyNever(() => logger.logInfo(any()));
    });

    test('Should skip transaction if account is missing', () {
      final TransactionEntity tx = _createTx(id: '1', accountId: 'acc1');
      final List<TransactionEntity> result = sanitizer.sanitizeTransactions(
        transactions: <TransactionEntity>[tx],
        validAccountIds: <String>{}, // No valid accounts
        validCategoryIds: <String>{},
        validSavingGoalIds: <String>{},
      );

      expect(result, isEmpty);
      verify(() => logger.logInfo(any())).called(1);
    });

    test('Should clear category if missing', () {
      final TransactionEntity tx = _createTx(
        id: '1',
        accountId: 'acc1',
        categoryId: 'cat1',
      );
      final List<TransactionEntity> result = sanitizer.sanitizeTransactions(
        transactions: <TransactionEntity>[tx],
        validAccountIds: <String>{'acc1'},
        validCategoryIds: <String>{}, // Missing cat1
        validSavingGoalIds: <String>{},
      );

      expect(result.length, 1);
      expect(result.first.categoryId, isNull);
      verify(() => logger.logInfo(any())).called(1);
    });

    test('Should clear saving goal if missing', () {
      final TransactionEntity tx = _createTx(
        id: '1',
        accountId: 'acc1',
        savingGoalId: 'goal1',
      );
      final List<TransactionEntity> result = sanitizer.sanitizeTransactions(
        transactions: <TransactionEntity>[tx],
        validAccountIds: <String>{'acc1'},
        validCategoryIds: <String>{},
        validSavingGoalIds: <String>{}, // Missing goal1
      );

      expect(result.length, 1);
      expect(result.first.savingGoalId, isNull);
      verify(() => logger.logInfo(any())).called(1);
    });
  });

  group('SyncDataSanitizer - RecurringRules', () {
    test('Should skip rule if account is missing', () {
      final RecurringRule rule = _createRule(
        id: '1',
        accountId: 'acc1',
        categoryId: 'cat1',
      );
      final List<RecurringRule> result = sanitizer.sanitizeRecurringRules(
        rules: <RecurringRule>[rule],
        validAccountIds: <String>{},
        validCategoryIds: <String>{},
      );

      expect(result, isEmpty);
      verify(() => logger.logInfo(any())).called(1);
    });

    test('Should skip rule if category is missing', () {
      final RecurringRule rule = _createRule(
        id: '1',
        accountId: 'acc1',
        categoryId: 'cat1',
      );
      final List<RecurringRule> result = sanitizer.sanitizeRecurringRules(
        rules: <RecurringRule>[rule],
        validAccountIds: <String>{'acc1'},
        validCategoryIds: <String>{}, // Missing cat1
      );

      expect(result, isEmpty);
      verify(() => logger.logInfo(any())).called(1);
    });
  });

  group('SyncDataSanitizer - BudgetInstances', () {
    test('Should skip instance if budget is missing', () {
      final BudgetInstance instance = _createInstance(
        id: '1',
        budgetId: 'bud1',
      );
      final List<BudgetInstance> result = sanitizer.sanitizeBudgetInstances(
        instances: <BudgetInstance>[instance],
        validBudgetIds: <String>{}, // Missing bud1
      );

      expect(result, isEmpty);
      verify(() => logger.logInfo(any())).called(1);
    });

    test('Should keep valid instance', () {
      final BudgetInstance instance = _createInstance(
        id: '1',
        budgetId: 'bud1',
      );
      final List<BudgetInstance> result = sanitizer.sanitizeBudgetInstances(
        instances: <BudgetInstance>[instance],
        validBudgetIds: <String>{'bud1'},
      );

      expect(result.length, 1);
      verifyNever(() => logger.logInfo(any()));
    });
  });
}

TransactionEntity _createTx({
  required String id,
  required String accountId,
  String? categoryId,
  String? savingGoalId,
}) {
  return TransactionEntity(
    id: id,
    accountId: accountId,
    categoryId: categoryId,
    savingGoalId: savingGoalId,
    amount: 100,
    date: DateTime.now(),
    type: TransactionType.expense.storageValue,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

RecurringRule _createRule({
  required String id,
  required String accountId,
  required String categoryId,
}) {
  return RecurringRule(
    id: id,
    title: 'Rule',
    accountId: accountId,
    categoryId: categoryId,
    amount: 100,
    currency: 'RUB',
    startAt: DateTime.now(),
    timezone: 'UTC',
    rrule: 'FREQ=MONTHLY',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

BudgetInstance _createInstance({required String id, required String budgetId}) {
  return BudgetInstance(
    id: id,
    budgetId: budgetId,
    periodStart: DateTime.now(),
    periodEnd: DateTime.now().add(const Duration(days: 30)),
    amount: 1000,
    status: BudgetInstanceStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
