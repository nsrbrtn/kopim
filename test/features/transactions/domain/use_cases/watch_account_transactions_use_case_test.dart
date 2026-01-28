import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_account_transactions_use_case.dart';

void main() {
  group('WatchAccountTransactionsUseCase', () {
    late StreamController<List<TransactionEntity>> transactionController;
    late StreamController<List<CreditEntity>> creditController;
    late WatchAccountTransactionsUseCase useCase;

    setUp(() {
      transactionController = StreamController<List<TransactionEntity>>();
      creditController = StreamController<List<CreditEntity>>();
      useCase = WatchAccountTransactionsUseCase(
        transactionRepository: _InMemoryTransactionRepository(
          transactionController.stream,
        ),
        creditRepository: _InMemoryCreditRepository(creditController.stream),
      );
    });

    tearDown(() async {
      await transactionController.close();
      await creditController.close();
    });

    test('includes credit payments by category for credit account', () async {
      final DateTime now = DateTime.utc(2026, 1, 10);
      final TransactionEntity payment = _transaction(
        id: 't1',
        accountId: 'cash',
        categoryId: 'credit_cat',
        date: now,
      );
      final TransactionEntity other = _transaction(
        id: 't2',
        accountId: 'cash',
        categoryId: 'other_cat',
        date: now,
      );
      final CreditEntity credit = _credit(
        id: 'c1',
        accountId: 'credit_acc',
        categoryId: 'credit_cat',
      );

      final Future<List<TransactionEntity>> result = useCase
          .call(accountId: 'credit_acc')
          .first;

      creditController.add(<CreditEntity>[credit]);
      transactionController.add(<TransactionEntity>[payment, other]);

      expect(await result, <TransactionEntity>[payment]);
    });

    test('includes direct and transfer transactions for account', () async {
      final DateTime now = DateTime.utc(2026, 1, 10);
      final TransactionEntity direct = _transaction(
        id: 't1',
        accountId: 'acc',
        categoryId: 'cat',
        date: now,
      );
      final TransactionEntity transfer = _transaction(
        id: 't2',
        accountId: 'source',
        categoryId: null,
        date: now,
        transferAccountId: 'acc',
        type: 'transfer',
      );

      final Future<List<TransactionEntity>> result = useCase
          .call(accountId: 'acc')
          .first;

      creditController.add(<CreditEntity>[]);
      transactionController.add(<TransactionEntity>[direct, transfer]);

      expect(await result, <TransactionEntity>[direct, transfer]);
    });
  });
}

TransactionEntity _transaction({
  required String id,
  required String accountId,
  required String? categoryId,
  required DateTime date,
  String? transferAccountId,
  String type = 'expense',
}) {
  return TransactionEntity(
    id: id,
    accountId: accountId,
    transferAccountId: transferAccountId,
    categoryId: categoryId,
    amountMinor: BigInt.from(1000),
    amountScale: 2,
    date: date,
    note: null,
    type: type,
    createdAt: date,
    updatedAt: date,
  );
}

CreditEntity _credit({
  required String id,
  required String accountId,
  required String categoryId,
}) {
  final DateTime now = DateTime.utc(2026, 1, 1);
  return CreditEntity(
    id: id,
    accountId: accountId,
    categoryId: categoryId,
    interestRate: 0,
    termMonths: 12,
    startDate: now,
    paymentDay: 10,
    createdAt: now,
    updatedAt: now,
  );
}

class _InMemoryTransactionRepository implements TransactionRepository {
  _InMemoryTransactionRepository(this._stream);

  final Stream<List<TransactionEntity>> _stream;

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) =>
      _stream;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _stream;

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) => const Stream<List<AccountMonthlyTotals>>.empty();

  @override
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) => const Stream<List<TransactionCategoryTotals>>.empty();

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyCashflowTotals>>.empty();

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyBalanceTotals>>.empty();

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<BudgetExpenseTotals>>.empty();

  @override
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<TransactionEntity>>.empty();

  @override
  Future<List<TransactionEntity>> loadTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findLatestByCategoryId(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }
}

class _InMemoryCreditRepository implements CreditRepository {
  _InMemoryCreditRepository(this._stream);

  final Stream<List<CreditEntity>> _stream;

  @override
  Stream<List<CreditEntity>> watchCredits() => _stream;

  @override
  Future<List<CreditEntity>> getCredits() {
    throw UnimplementedError();
  }

  @override
  Future<CreditEntity?> getCreditByAccountId(String accountId) {
    throw UnimplementedError();
  }

  @override
  Future<CreditEntity?> getCreditByCategoryId(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<void> addCredit(CreditEntity credit) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCredit(CreditEntity credit) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCredit(String id) {
    throw UnimplementedError();
  }
}
