import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/data/services/transaction_balance_helper.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  SavingGoalRepositoryImpl({
    required db.AppDatabase database,
    required SavingGoalDao savingGoalDao,
    required AccountDao accountDao,
    required TransactionDao transactionDao,
    required GoalContributionDao goalContributionDao,
    required OutboxDao outboxDao,
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
    Uuid? uuidGenerator,
    DateTime Function()? clock,
  }) : _database = database,
       _savingGoalDao = savingGoalDao,
       _accountDao = accountDao,
       _transactionDao = transactionDao,
       _contributionDao = goalContributionDao,
       _outboxDao = outboxDao,
       _analyticsService = analyticsService,
       _logger = loggerService,
       _uuid = uuidGenerator ?? const Uuid(),
       _clock = clock ?? DateTime.now;

  static const String _goalEntityType = 'saving_goal';
  static const String _transactionEntityType = 'transaction';
  static const String _accountEntityType = 'account';

  final db.AppDatabase _database;
  final SavingGoalDao _savingGoalDao;
  final AccountDao _accountDao;
  final TransactionDao _transactionDao;
  final GoalContributionDao _contributionDao;
  final OutboxDao _outboxDao;
  final AnalyticsService _analyticsService;
  final LoggerService _logger;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Stream<List<SavingGoal>> watchGoals({required bool includeArchived}) {
    return _savingGoalDao.watchGoals(includeArchived: includeArchived);
  }

  @override
  Future<List<SavingGoal>> loadGoals({required bool includeArchived}) {
    return _savingGoalDao.getGoals(includeArchived: includeArchived);
  }

  @override
  Future<SavingGoal?> findById(String id) {
    return _savingGoalDao.findById(id);
  }

  @override
  Future<SavingGoal?> findByName({
    required String userId,
    required String name,
  }) {
    return _savingGoalDao.findByName(userId: userId, name: name);
  }

  @override
  Future<void> create(SavingGoal goal) async {
    final DateTime now = _clock().toUtc();
    SavingGoal? persistedGoal;
    await _database.transaction(() async {
      final SavingGoal withAccount = await _ensureGoalAccount(goal, now);
      final SavingGoal toPersist = withAccount.copyWith(updatedAt: now);
      await _savingGoalDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _goalEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(toPersist),
      );
      persistedGoal = toPersist;
    });
    final SavingGoal toPersist = persistedGoal ?? goal;
    await _analyticsService.logEvent('savings_goal_create', <String, dynamic>{
      'goalId': toPersist.id,
      'target': toPersist.targetAmount,
    });
    _logger.logInfo('Saving goal created: ${toPersist.id}');
  }

  @override
  Future<void> update(SavingGoal goal) async {
    final DateTime now = _clock().toUtc();
    SavingGoal? persistedGoal;
    await _database.transaction(() async {
      final SavingGoal withAccount = await _ensureGoalAccount(goal, now);
      final SavingGoal toPersist = withAccount.copyWith(updatedAt: now);
      await _savingGoalDao.upsert(toPersist);
      await _syncGoalAccountName(goal: toPersist, timestamp: now);
      await _outboxDao.enqueue(
        entityType: _goalEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(toPersist),
      );
      persistedGoal = toPersist;
    });
    final SavingGoal toPersist = persistedGoal ?? goal;
    await _analyticsService.logEvent('savings_goal_update', <String, dynamic>{
      'goalId': toPersist.id,
      'target': toPersist.targetAmount,
    });
    _logger.logInfo('Saving goal updated: ${toPersist.id}');
  }

  @override
  Future<void> archive(String goalId, DateTime archivedAt) async {
    await _database.transaction(() async {
      await _savingGoalDao.archive(goalId, archivedAt);
      final SavingGoal? updated = await _savingGoalDao.findById(goalId);
      if (updated == null) {
        return;
      }
      await _outboxDao.enqueue(
        entityType: _goalEntityType,
        entityId: goalId,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(updated),
      );
    });
    await _analyticsService.logEvent('savings_goal_archive', <String, dynamic>{
      'goalId': goalId,
    });
    _logger.logInfo('Saving goal archived: $goalId');
  }

  @override
  Future<SavingGoal> addContribution({
    required SavingGoal goal,
    required int appliedDelta,
    required int newCurrentAmount,
    required DateTime contributedAt,
    required String sourceAccountId,
    String? contributionNote,
  }) async {
    final DateTime timestamp = contributedAt.toUtc();
    final SavingGoal persisted = await _database.transaction(() async {
      final SavingGoal ensuredGoal = await _ensureGoalAccount(goal, timestamp);
      final String? goalAccountId = ensuredGoal.accountId;
      if (goalAccountId == null || goalAccountId.isEmpty) {
        throw StateError('Saving goal account is not configured');
      }
      final SavingGoal updatedGoal = goal.copyWith(
        accountId: goalAccountId,
        currentAmount: newCurrentAmount,
        updatedAt: timestamp,
      );
      final String accountId = sourceAccountId;
      final db.AccountRow? sourceAccountRow = await _accountDao.findById(
        accountId,
      );
      if (sourceAccountRow == null) {
        throw StateError('Account not found for contribution');
      }
      final db.AccountRow? goalAccountRow = await _accountDao.findById(
        goalAccountId,
      );
      if (goalAccountRow == null) {
        throw StateError('Saving goal account not found');
      }
      if (accountId == goalAccountId) {
        throw StateError('Source and target accounts must be different');
      }
      if (sourceAccountRow.currency != goalAccountRow.currency) {
        throw StateError('Source and saving goal currencies must match');
      }
      final double amountDouble = appliedDelta / 100;
      final int scale = resolveCurrencyScale(sourceAccountRow.currency);
      final Money money = Money.fromDouble(
        amountDouble.abs(),
        currency: sourceAccountRow.currency,
        scale: scale,
      );
      final TransactionEntity transaction = TransactionEntity(
        id: _uuid.v4(),
        accountId: accountId,
        transferAccountId: goalAccountId,
        categoryId: null,
        savingGoalId: goal.id,
        amountMinor: money.minor,
        amountScale: scale,
        date: timestamp,
        note: _composeContributionNote(goal.name, contributionNote),
        type: 'transfer',
        createdAt: timestamp,
        updatedAt: timestamp,
      );
      await _transactionDao.upsert(transaction);
      await _outboxDao.enqueue(
        entityType: _transactionEntityType,
        entityId: transaction.id,
        operation: OutboxOperation.upsert,
        payload: _mapTransactionPayload(transaction),
      );
      final Map<String, MoneyAmount> effect = buildTransactionEffect(
        transaction: transaction,
        creditAccountId: null,
      );
      await _applyAccountEffect(effect, timestamp);
      await _contributionDao.insert(
        id: _uuid.v4(),
        goalId: goal.id,
        transactionId: transaction.id,
        amount: appliedDelta,
        createdAt: timestamp,
      );
      await _savingGoalDao.upsert(updatedGoal);
      await _outboxDao.enqueue(
        entityType: _goalEntityType,
        entityId: updatedGoal.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(updatedGoal),
      );
      return updatedGoal;
    });

    await _analyticsService
        .logEvent('savings_goal_contribution', <String, dynamic>{
          'goalId': persisted.id,
          'amount': appliedDelta,
          'sourceAccountId': sourceAccountId,
        });
    final String logNote =
        contributionNote != null && contributionNote.isNotEmpty
        ? ' с заметкой $contributionNote'
        : '';
    _logger.logInfo(
      'Добавлен взнос в ${persisted.id} на сумму $appliedDelta$logNote',
    );
    return persisted;
  }

  Future<SavingGoal> _ensureGoalAccount(
    SavingGoal goal,
    DateTime timestamp,
  ) async {
    if (goal.accountId != null && goal.accountId!.isNotEmpty) {
      final db.AccountRow? existing = await _accountDao.findById(
        goal.accountId!,
      );
      if (existing != null) {
        return goal;
      }
    }

    final db.AccountRow? primaryAccount = await _findPrimaryActiveAccount();
    final String currency = primaryAccount?.currency ?? 'USD';
    final int scale =
        primaryAccount?.currencyScale ?? resolveCurrencyScale(currency);
    final String accountId =
        goal.accountId != null && goal.accountId!.isNotEmpty
        ? goal.accountId!
        : _uuid.v4();
    final int initialMinor = goal.currentAmount;
    final AccountEntity account = AccountEntity(
      id: accountId,
      name: 'Копилка: ${goal.name}',
      balanceMinor: BigInt.from(initialMinor),
      openingBalanceMinor: BigInt.from(initialMinor),
      currency: currency,
      currencyScale: scale,
      type: 'savings',
      createdAt: timestamp,
      updatedAt: timestamp,
      isDeleted: false,
      isPrimary: false,
      isHidden: false,
    );
    await _accountDao.upsert(account);
    await _outboxDao.enqueue(
      entityType: _accountEntityType,
      entityId: account.id,
      operation: OutboxOperation.upsert,
      payload: _mapAccountPayload(account),
    );
    return goal.copyWith(accountId: account.id);
  }

  Future<db.AccountRow?> _findPrimaryActiveAccount() async {
    final List<db.AccountRow> accounts = await _accountDao.getActiveAccounts();
    for (final db.AccountRow row in accounts) {
      if (row.isPrimary) {
        return row;
      }
    }
    return accounts.isNotEmpty ? accounts.first : null;
  }

  Future<void> _syncGoalAccountName({
    required SavingGoal goal,
    required DateTime timestamp,
  }) async {
    final String? accountId = goal.accountId;
    if (accountId == null || accountId.isEmpty) {
      return;
    }
    final db.AccountRow? row = await _accountDao.findById(accountId);
    if (row == null || row.isDeleted) {
      return;
    }
    final String expectedName = 'Копилка: ${goal.name}';
    if (row.name == expectedName) {
      return;
    }
    final AccountEntity updated = _mapAccountRow(
      row,
    ).copyWith(name: expectedName, updatedAt: timestamp);
    await _accountDao.upsert(updated);
    await _outboxDao.enqueue(
      entityType: _accountEntityType,
      entityId: updated.id,
      operation: OutboxOperation.upsert,
      payload: _mapAccountPayload(updated),
    );
  }

  String _composeContributionNote(String goalName, String? note) {
    final String base = 'Накопление: $goalName';
    if (note == null || note.isEmpty) {
      return base;
    }
    return '$base — $note';
  }

  Map<String, dynamic> _mapGoalPayload(SavingGoal goal) {
    final Map<String, dynamic> json = goal.toJson();
    json['createdAt'] = goal.createdAt.toIso8601String();
    json['updatedAt'] = goal.updatedAt.toIso8601String();
    json['archivedAt'] = goal.archivedAt?.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapTransactionPayload(TransactionEntity transaction) {
    final Map<String, dynamic> json = transaction.toJson();
    json['createdAt'] = transaction.createdAt.toIso8601String();
    json['updatedAt'] = transaction.updatedAt.toIso8601String();
    json['date'] = transaction.date.toIso8601String();
    json['amountMinor'] = transaction.amountMinor?.toString();
    json['amountScale'] = transaction.amountScale;
    return json;
  }

  Future<void> _applyAccountEffect(
    Map<String, MoneyAmount> effect,
    DateTime updatedAt,
  ) async {
    for (final MapEntry<String, MoneyAmount> entry in effect.entries) {
      final db.AccountRow? accountRow = await _accountDao.findById(entry.key);
      if (accountRow == null) {
        throw StateError('Account not found for id ${entry.key}');
      }
      final int scale = accountRow.currencyScale;
      final MoneyAmount delta = rescaleMoneyAmount(entry.value, scale);
      final AccountEntity updatedAccount = _mapAccountRow(accountRow).copyWith(
        balanceMinor: BigInt.parse(accountRow.balanceMinor) + delta.minor,
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
  }

  AccountEntity _mapAccountRow(db.AccountRow row) {
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

  Map<String, dynamic> _mapAccountPayload(AccountEntity account) {
    final Map<String, dynamic> json = account.toJson();
    json['updatedAt'] = account.updatedAt.toIso8601String();
    json['createdAt'] = account.createdAt.toIso8601String();
    json['balanceMinor'] = account.balanceMinor?.toString();
    json['openingBalanceMinor'] = account.openingBalanceMinor?.toString();
    json['currencyScale'] = account.currencyScale;
    return json;
  }
}
