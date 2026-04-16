import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/overview/domain/models/overview_safety_cushion.dart';
import 'package:kopim/features/overview/domain/use_cases/watch_overview_safety_cushion_use_case.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

void main() {
  group('WatchOverviewSafetyCushionUseCase', () {
    test(
      'считает покрытие месяцев и safety score для базового сценария',
      () async {
        final DateTime reference = DateTime(2026, 2, 25);
        final _AccountRepositoryFake accountRepository = _AccountRepositoryFake(
          accounts: <AccountEntity>[
            _account(id: 'cash', type: 'cash', balanceMinor: 600000),
          ],
        );
        final _TransactionRepositoryFake transactionRepository =
            _TransactionRepositoryFake(
              transactions: <TransactionEntity>[
                _expense('tx-dec', 'cash', 100000, DateTime(2025, 12, 12)),
                _expense('tx-jan', 'cash', 100000, DateTime(2026, 1, 12)),
                _expense('tx-feb', 'cash', 100000, DateTime(2026, 2, 12)),
              ],
            );
        final _SavingGoalRepositoryFake goalRepository =
            _SavingGoalRepositoryFake(
              goals: <SavingGoal>[
                _goal(targetAmount: 100000, currentAmount: 50000),
              ],
            );

        final WatchOverviewSafetyCushionUseCase useCase =
            WatchOverviewSafetyCushionUseCase(
              accountRepository: accountRepository,
              transactionRepository: transactionRepository,
              savingGoalRepository: goalRepository,
            );

        final OverviewSafetyCushion result = await useCase
            .call(reference: reference)
            .first;

        expect(result.monthsCovered, closeTo(6.0, 0.001));
        expect(result.progress, closeTo(1.0, 0.001));
        expect(result.safetyScore, 85);
        expect(result.state, OverviewSafetyCushionState.safe);
      },
    );

    test('игнорирует liability-счета в ликвидных активах', () async {
      final DateTime reference = DateTime(2026, 2, 25);
      final _AccountRepositoryFake accountRepository = _AccountRepositoryFake(
        accounts: <AccountEntity>[
          _account(id: 'credit', type: 'credit_card', balanceMinor: 500000),
        ],
      );
      final _TransactionRepositoryFake transactionRepository =
          _TransactionRepositoryFake(
            transactions: <TransactionEntity>[
              _expense('tx-dec', 'credit', 100000, DateTime(2025, 12, 12)),
              _expense('tx-jan', 'credit', 100000, DateTime(2026, 1, 12)),
              _expense('tx-feb', 'credit', 100000, DateTime(2026, 2, 12)),
            ],
          );
      final _SavingGoalRepositoryFake goalRepository =
          _SavingGoalRepositoryFake(goals: const <SavingGoal>[]);

      final WatchOverviewSafetyCushionUseCase useCase =
          WatchOverviewSafetyCushionUseCase(
            accountRepository: accountRepository,
            transactionRepository: transactionRepository,
            savingGoalRepository: goalRepository,
          );

      final OverviewSafetyCushion result = await useCase
          .call(reference: reference)
          .first;

      expect(result.monthsCovered, 0);
      expect(result.progress, 0);
      expect(result.safetyScore, 0);
      expect(result.state, OverviewSafetyCushionState.risk);
    });

    test('учитывает фильтр счетов', () async {
      final DateTime reference = DateTime(2026, 2, 25);
      final _AccountRepositoryFake accountRepository = _AccountRepositoryFake(
        accounts: <AccountEntity>[
          _account(id: 'a', type: 'cash', balanceMinor: 120000),
          _account(id: 'b', type: 'cash', balanceMinor: 600000),
        ],
      );
      final _TransactionRepositoryFake transactionRepository =
          _TransactionRepositoryFake(
            transactions: <TransactionEntity>[
              _expense('a-dec', 'a', 40000, DateTime(2025, 12, 10)),
              _expense('a-jan', 'a', 40000, DateTime(2026, 1, 10)),
              _expense('a-feb', 'a', 40000, DateTime(2026, 2, 10)),
              _expense('b-dec', 'b', 100000, DateTime(2025, 12, 12)),
              _expense('b-jan', 'b', 100000, DateTime(2026, 1, 12)),
              _expense('b-feb', 'b', 100000, DateTime(2026, 2, 12)),
            ],
          );
      final _SavingGoalRepositoryFake goalRepository =
          _SavingGoalRepositoryFake(goals: const <SavingGoal>[]);

      final WatchOverviewSafetyCushionUseCase useCase =
          WatchOverviewSafetyCushionUseCase(
            accountRepository: accountRepository,
            transactionRepository: transactionRepository,
            savingGoalRepository: goalRepository,
          );

      final OverviewSafetyCushion onlyA = await useCase
          .call(reference: reference, accountIdsFilter: <String>{'a'})
          .first;
      final OverviewSafetyCushion all = await useCase
          .call(reference: reference)
          .first;

      expect(onlyA.monthsCovered, closeTo(3.0, 0.001));
      expect(all.monthsCovered, closeTo(5.142, 0.01));
    });
  });
}

AccountEntity _account({
  required String id,
  required String type,
  required int balanceMinor,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return AccountEntity(
    id: id,
    name: id,
    balanceMinor: BigInt.from(balanceMinor),
    openingBalanceMinor: BigInt.from(balanceMinor),
    currency: 'RUB',
    currencyScale: 2,
    type: type,
    createdAt: now,
    updatedAt: now,
  );
}

SavingGoal _goal({required int targetAmount, required int currentAmount}) {
  final DateTime now = DateTime(2026, 1, 1);
  return SavingGoal(
    id: 'goal-1',
    userId: 'u-1',
    name: 'goal',
    targetAmount: targetAmount,
    currentAmount: currentAmount,
    createdAt: now,
    updatedAt: now,
  );
}

TransactionEntity _expense(
  String id,
  String accountId,
  int amountMinor,
  DateTime date,
) {
  return TransactionEntity(
    id: id,
    accountId: accountId,
    amountMinor: BigInt.from(-amountMinor),
    amountScale: 2,
    date: date,
    type: TransactionType.expense.storageValue,
    createdAt: date,
    updatedAt: date,
  );
}

class _AccountRepositoryFake implements AccountRepository {
  _AccountRepositoryFake({required List<AccountEntity> accounts})
    : _accounts = accounts;

  final List<AccountEntity> _accounts;

  @override
  Future<AccountEntity?> findById(String id) async {
    for (final AccountEntity account in _accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  @override
  Future<List<AccountEntity>> loadAccounts() async => _accounts;

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(AccountEntity account) {
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountEntity>> watchAccounts() {
    return Stream<List<AccountEntity>>.value(_accounts);
  }
}

class _TransactionRepositoryFake implements TransactionRepository {
  _TransactionRepositoryFake({required List<TransactionEntity> transactions})
    : _transactions = transactions;

  final List<TransactionEntity> _transactions;

  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> findByGroupId(String groupId) async {
    return const <TransactionEntity>[];
  }

  @override
  Future<TransactionEntity?> findByIdempotencyKey(String idempotencyKey) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findLatestByCategoryId(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> loadTransactions() async => _transactions;

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    return Stream<List<TransactionEntity>>.value(_transactions);
  }
}

class _SavingGoalRepositoryFake implements SavingGoalRepository {
  _SavingGoalRepositoryFake({required List<SavingGoal> goals}) : _goals = goals;

  final List<SavingGoal> _goals;

  @override
  Future<SavingGoal> addContribution({
    required SavingGoal goal,
    required int appliedDelta,
    required int newCurrentAmount,
    required DateTime contributedAt,
    required String sourceAccountId,
    String? storageAccountId,
    String? contributionNote,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> archive(String goalId, DateTime archivedAt) {
    throw UnimplementedError();
  }

  @override
  Future<void> create(SavingGoal goal) {
    throw UnimplementedError();
  }

  @override
  Future<SavingGoal?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<SavingGoal?> findByName({
    required String userId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<SavingGoal>> loadGoals({required bool includeArchived}) async =>
      _goals;

  @override
  Future<void> update(SavingGoal goal) {
    throw UnimplementedError();
  }

  @override
  Stream<List<SavingGoal>> watchGoals({required bool includeArchived}) {
    return Stream<List<SavingGoal>>.value(_goals);
  }
}
