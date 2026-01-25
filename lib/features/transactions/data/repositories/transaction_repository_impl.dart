import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/services/transaction_balance_helper.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required db.AppDatabase database,
    required TransactionDao transactionDao,
    required AccountDao accountDao,
    required CreditDao creditDao,
    required SavingGoalDao savingGoalDao,
    required GoalContributionDao goalContributionDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _transactionDao = transactionDao,
       _accountDao = accountDao,
       _creditDao = creditDao,
       _savingGoalDao = savingGoalDao,
       _contributionDao = goalContributionDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final TransactionDao _transactionDao;
  final AccountDao _accountDao;
  final CreditDao _creditDao;
  final SavingGoalDao _savingGoalDao;
  final GoalContributionDao _contributionDao;
  final OutboxDao _outboxDao;
  static const String _entityType = 'transaction';
  static const String _accountEntityType = 'account';
  static const String _savingGoalEntityType = 'saving_goal';
  static DateTime _utcNow() => DateTime.now().toUtc();

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    return _transactionDao.watchActiveTransactions().map(
      (List<db.TransactionRow> rows) =>
          List<TransactionEntity>.unmodifiable(rows.map(_mapToDomain)),
    );
  }

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    final Stream<List<db.TransactionRow>> rowsStream = _transactionDao
        .watchRecentTransactions(limit: limit);
    return rowsStream.map(
      (List<db.TransactionRow> rows) =>
          List<TransactionEntity>.unmodifiable(rows.map(_mapToDomain)),
    );
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    return _transactionDao
        .watchAccountMonthlyTotals(start: start, end: end)
        .map(
          (List<AccountMonthlyTotalsRow> rows) => rows
              .map(
                (AccountMonthlyTotalsRow row) => AccountMonthlyTotals(
                  accountId: row.accountId,
                  income: row.income,
                  expense: row.expense,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) {
    return _transactionDao
        .watchAnalyticsCategoryTotals(
          start: start,
          end: end,
          accountIds: accountIds,
          accountId: accountId,
        )
        .map(
          (List<AnalyticsCategoryTotalsRow> rows) => rows
              .map(
                (AnalyticsCategoryTotalsRow row) => TransactionCategoryTotals(
                  categoryId: row.categoryId,
                  rootCategoryId: row.rootCategoryId,
                  income: row.income,
                  expense: row.expense,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) {
    return _transactionDao
        .watchMonthlyCashflowTotals(
          start: start,
          end: end,
          nowInclusive: nowInclusive,
          accountIds: accountIds,
        )
        .map(
          (List<MonthlyCashflowTotalsRow> rows) => rows
              .map(
                (MonthlyCashflowTotalsRow row) => MonthlyCashflowTotals(
                  month: _parseMonthKey(row.monthKey),
                  income: row.income,
                  expense: row.expense,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    return _transactionDao
        .watchMonthlyBalanceTotals(
          start: start,
          end: end,
          accountIds: accountIds,
        )
        .map(
          (List<MonthlyBalanceTotalsRow> rows) => rows
              .map(
                (MonthlyBalanceTotalsRow row) => MonthlyBalanceTotals(
                  month: _parseMonthKey(row.monthKey),
                  maxBalance: row.maxBalance,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    return _transactionDao
        .watchBudgetExpenseTotals(
          start: start,
          end: end,
          accountIds: accountIds,
        )
        .map(
          (List<BudgetExpenseTotalsRow> rows) => rows
              .map(
                (BudgetExpenseTotalsRow row) => BudgetExpenseTotals(
                  accountId: row.accountId,
                  categoryId: row.categoryId,
                  expense: row.expense,
                ),
              )
              .toList(growable: false),
        );
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
    return _transactionDao
        .watchCategoryTransactions(
          start: start,
          end: end,
          categoryIds: categoryIds,
          includeUncategorized: includeUncategorized,
          type: type,
          accountIds: accountIds,
        )
        .map(
          (List<db.TransactionRow> rows) =>
              List<TransactionEntity>.unmodifiable(rows.map(_mapToDomain)),
        );
  }

  @override
  Future<List<TransactionEntity>> loadTransactions() async {
    final List<db.TransactionRow> rows = await _transactionDao
        .getActiveTransactions();
    return rows.map(_mapToDomain).toList(growable: false);
  }

  @override
  Future<TransactionEntity?> findById(String id) async {
    final db.TransactionRow? row = await _transactionDao.findById(id);
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<void> upsert(TransactionEntity transaction) async {
    final DateTime now = _utcNow();
    final TransactionEntity toPersist = transaction.copyWith(updatedAt: now);
    await _database.transaction(() async {
      final db.TransactionRow? previousRow = await _transactionDao.findById(
        toPersist.id,
      );
      final TransactionEntity? previous = previousRow != null
          ? _mapToDomain(previousRow)
          : null;
      await _transactionDao.upsert(toPersist);
      await _applyAccountBalanceChanges(
        previous: previous,
        current: toPersist,
        updatedAt: now,
      );
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapTransactionPayload(toPersist),
      );
    });
  }

  DateTime _parseMonthKey(String key) {
    final DateTime fallback = _utcNow();
    final List<String> parts = key.split('-');
    if (parts.length != 2) {
      return DateTime.utc(fallback.year, fallback.month);
    }
    final int year = int.tryParse(parts[0]) ?? fallback.year;
    final int month = int.tryParse(parts[1]) ?? fallback.month;
    return DateTime.utc(year, month);
  }

  @override
  Future<void> softDelete(String id) async {
    final DateTime now = _utcNow();
    await _database.transaction(() async {
      final db.TransactionRow? row = await _transactionDao.findById(id);
      if (row == null) return;
      final TransactionEntity previous = _mapToDomain(row);
      await _applyAccountBalanceChanges(
        previous: previous,
        current: null,
        updatedAt: now,
      );
      await _transactionDao.markDeleted(id, now);
      await _handleSavingGoalRollback(row, now);
      final Map<String, dynamic> payload = _mapTransactionPayload(
        previous.copyWith(isDeleted: true, updatedAt: now),
      );
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: payload,
      );
    });
  }

  Future<void> _handleSavingGoalRollback(
    db.TransactionRow row,
    DateTime deletedAt,
  ) async {
    final String? goalId = row.savingGoalId;
    if (goalId == null) {
      return;
    }
    final db.GoalContributionRow? contribution = await _contributionDao
        .findByTransactionId(row.id);
    if (contribution == null) {
      await _contributionDao.deleteByTransactionId(row.id);
      return;
    }
    final SavingGoal? goal = await _savingGoalDao.findById(goalId);
    if (goal == null) {
      await _contributionDao.deleteById(contribution.id);
      return;
    }
    final int updatedAmount = (goal.currentAmount - contribution.amount).clamp(
      0,
      goal.targetAmount,
    );
    final SavingGoal updatedGoal = goal.copyWith(
      currentAmount: updatedAmount,
      updatedAt: deletedAt,
    );
    await _savingGoalDao.upsert(updatedGoal);
    await _outboxDao.enqueue(
      entityType: _savingGoalEntityType,
      entityId: updatedGoal.id,
      operation: OutboxOperation.upsert,
      payload: _mapGoalPayload(updatedGoal),
    );
    await _contributionDao.deleteById(contribution.id);
  }

  Future<void> _applyAccountBalanceChanges({
    required TransactionEntity? previous,
    required TransactionEntity? current,
    required DateTime updatedAt,
  }) async {
    if (previous == null && current == null) {
      return;
    }
    final Map<String, MoneyAmount> previousEffect = previous != null
        ? await _buildAccountEffect(previous)
        : <String, MoneyAmount>{};
    final Map<String, MoneyAmount> currentEffect = current != null
        ? await _buildAccountEffect(current)
        : <String, MoneyAmount>{};
    final Set<String> affectedAccounts = <String>{
      ...previousEffect.keys,
      ...currentEffect.keys,
    };
    for (final String accountId in affectedAccounts) {
      final MoneyAmount? currentDelta = currentEffect[accountId];
      final MoneyAmount? previousDelta = previousEffect[accountId];
      final int scale = (currentDelta ?? previousDelta)?.scale ?? 2;
      final MoneyAmount normalizedCurrent = currentDelta != null
          ? rescaleMoneyAmount(currentDelta, scale)
          : MoneyAmount(minor: BigInt.zero, scale: scale);
      final MoneyAmount normalizedPrevious = previousDelta != null
          ? rescaleMoneyAmount(previousDelta, scale)
          : MoneyAmount(minor: BigInt.zero, scale: scale);
      final MoneyAmount delta = MoneyAmount(
        minor: normalizedCurrent.minor - normalizedPrevious.minor,
        scale: scale,
      );
      if (delta.minor == BigInt.zero) {
        continue;
      }
      await _applyAccountDelta(accountId, delta, updatedAt);
    }
  }

  Future<Map<String, MoneyAmount>> _buildAccountEffect(
    TransactionEntity transaction,
  ) async {
    final String? categoryId = transaction.categoryId;
    final db.CreditRow? creditRow = categoryId != null
        ? await _creditDao.findByCategoryId(categoryId)
        : null;
    final String? creditAccountId = creditRow?.accountId;
    return buildTransactionEffect(
      transaction: transaction,
      creditAccountId: creditAccountId,
    );
  }

  Future<void> _applyAccountDelta(
    String accountId,
    MoneyAmount delta,
    DateTime updatedAt,
  ) async {
    final db.AccountRow? row = await _accountDao.findById(accountId);
    if (row == null) {
      throw StateError('Account not found for id $accountId');
    }
    final int scale = row.currencyScale;
    final MoneyAmount normalized = rescaleMoneyAmount(delta, scale);
    final BigInt updatedMinor =
        BigInt.parse(row.balanceMinor) + normalized.minor;
    final AccountEntity updatedAccount = _mapAccountToDomain(row).copyWith(
      balanceMinor: updatedMinor,
      currencyScale: scale,
      updatedAt: updatedAt,
    );
    await _accountDao.upsert(updatedAccount);
    await _outboxDao.enqueue(
      entityType: _accountEntityType,
      entityId: updatedAccount.id,
      operation: OutboxOperation.upsert,
      payload: _mapAccountPayload(updatedAccount),
    );
  }

  Map<String, dynamic> _mapTransactionPayload(TransactionEntity transaction) {
    final Map<String, dynamic> json = transaction.toJson();
    json['createdAt'] = transaction.createdAt.toIso8601String();
    json['updatedAt'] = transaction.updatedAt.toIso8601String();
    json['date'] = transaction.date.toIso8601String();
    json['savingGoalId'] = transaction.savingGoalId;
    json['amountMinor'] = transaction.amountMinor?.toString();
    json['amountScale'] = transaction.amountScale;
    return json;
  }

  Map<String, dynamic> _mapGoalPayload(SavingGoal goal) {
    final Map<String, dynamic> json = goal.toJson();
    json['createdAt'] = goal.createdAt.toIso8601String();
    json['updatedAt'] = goal.updatedAt.toIso8601String();
    json['archivedAt'] = goal.archivedAt?.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapAccountPayload(AccountEntity account) {
    final Map<String, dynamic> json = account.toJson();
    json['updatedAt'] = account.updatedAt.toIso8601String();
    json['createdAt'] = account.createdAt.toIso8601String();
    json['isPrimary'] = account.isPrimary;
    json['color'] = account.color;
    json['gradientId'] = account.gradientId;
    json['iconName'] = account.iconName;
    json['iconStyle'] = account.iconStyle;
    final MoneyAmount balance = account.balanceAmount;
    final MoneyAmount openingBalance = account.openingBalanceAmount;
    json['balance'] = balance.toDouble();
    json['openingBalance'] = openingBalance.toDouble();
    json['balanceMinor'] = balance.minor.toString();
    json['openingBalanceMinor'] = openingBalance.minor.toString();
    json['currencyScale'] = account.currencyScale;
    return json;
  }

  TransactionEntity _mapToDomain(db.TransactionRow row) {
    return TransactionEntity(
      id: row.id,
      accountId: row.accountId,
      transferAccountId: row.transferAccountId,
      categoryId: row.categoryId,
      savingGoalId: row.savingGoalId,
      amountMinor: BigInt.parse(row.amountMinor),
      amountScale: row.amountScale,
      date: row.date,
      note: row.note,
      type: row.type,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }

  AccountEntity _mapAccountToDomain(db.AccountRow row) {
    return AccountEntity(
      id: row.id,
      name: row.name,
      balanceMinor: BigInt.parse(row.balanceMinor),
      openingBalanceMinor: BigInt.parse(row.openingBalanceMinor),
      currency: row.currency,
      currencyScale: row.currencyScale,
      type: row.type,
      color: row.color,
      gradientId: row.gradientId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      isPrimary: row.isPrimary,
      isHidden: row.isHidden,
      iconName: row.iconName,
      iconStyle: row.iconStyle,
    );
  }
}
