import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/presentation/controllers/edit_account_form_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:riverpod/riverpod.dart';

class _EmptyTransactionRepository implements TransactionRepository {
  @override
  Stream<List<TransactionEntity>> watchTransactions() =>
      const Stream<List<TransactionEntity>>.empty();

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) =>
      const Stream<List<TransactionEntity>>.empty();

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
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<TransactionEntity>>.empty();

  @override
  Future<List<TransactionEntity>> loadTransactions() async =>
      const <TransactionEntity>[];

  @override
  Future<TransactionEntity?> findById(String id) async => null;

  @override
  Future<void> upsert(TransactionEntity transaction) async {}

  @override
  Future<void> softDelete(String id) async {}
}

void main() {
  group('EditAccountFormController', () {
    test('updates account using addAccountUseCase', () async {
      final _RecordingAccountRepository repository =
          _RecordingAccountRepository();
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types, the Override type is internal to riverpod
        overrides: [
          addAccountUseCaseProvider.overrideWithValue(
            AddAccountUseCase(repository),
          ),
          transactionRepositoryProvider.overrideWithValue(
            _EmptyTransactionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DateTime createdAt = DateTime.utc(2024, 1, 1);
      final AccountEntity original = AccountEntity(
        id: 'acc-1',
        name: 'Wallet',
        balanceMinor: BigInt.from(10000),
        currency: 'USD',
        currencyScale: 2,
        type: 'cash',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final EditAccountFormController controller = container.read(
        editAccountFormControllerProvider(original).notifier,
      );

      controller
        ..updateName(' Wallet Plus ')
        ..updateBalance('250,75')
        ..updateCurrency('EUR')
        ..updateIsPrimary(true);

      await controller.submit();

      expect(repository.lastUpserted, isNotNull);
      final AccountEntity updated = repository.lastUpserted!;
      expect(updated.id, original.id);
      expect(updated.name, 'Wallet Plus');
      expect(updated.balanceAmount.toDouble(), closeTo(250.75, 1e-6));
      expect(updated.currency, 'EUR');
      expect(updated.type, original.type);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);
      expect(updated.isPrimary, isTrue);

      final EditAccountFormState state = container.read(
        editAccountFormControllerProvider(original),
      );
      expect(state.submissionSuccess, isTrue);
      expect(state.isPrimary, isTrue);
    });

    test('validates empty name and invalid balance', () async {
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types, the Override type is internal to riverpod
        overrides: [
          addAccountUseCaseProvider.overrideWithValue(
            AddAccountUseCase(_RecordingAccountRepository()),
          ),
          transactionRepositoryProvider.overrideWithValue(
            _EmptyTransactionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DateTime now = DateTime.utc(2024, 1, 1);
      final AccountEntity original = AccountEntity(
        id: 'acc-2',
        name: 'Savings',
        balanceMinor: BigInt.from(50000),
        currency: 'USD',
        currencyScale: 2,
        type: 'bank',
        createdAt: now,
        updatedAt: now,
      );

      final EditAccountFormController controller = container.read(
        editAccountFormControllerProvider(original).notifier,
      );

      controller
        ..updateName('   ')
        ..updateBalance('abc');

      await controller.submit();

      final EditAccountFormState state = container.read(
        editAccountFormControllerProvider(original),
      );

      expect(state.nameError, EditAccountFieldError.emptyName);
      expect(state.balanceError, EditAccountFieldError.invalidBalance);
      expect(state.submissionSuccess, isFalse);
    });
  });
}

class _RecordingAccountRepository implements AccountRepository {
  AccountEntity? lastUpserted;

  @override
  Future<AccountEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> loadAccounts() {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(AccountEntity account) async {
    lastUpserted = account;
  }

  @override
  Stream<List<AccountEntity>> watchAccounts() {
    throw UnimplementedError();
  }
}
