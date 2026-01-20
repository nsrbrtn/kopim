import 'dart:async';
import 'dart:collection';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/outbox/outbox_payload_normalizer.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/sync_data_sanitizer.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/data/sources/remote/tag_remote_data_source.dart';
import 'package:kopim/features/tags/data/sources/remote/transaction_tag_remote_data_source.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_card_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/debt_remote_data_source.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/payment_reminder_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/upcoming_payment_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AuthSyncService {
  AuthSyncService({
    required AppDatabase database,
    required OutboxDao outboxDao,
    required AccountDao accountDao,
    required CategoryDao categoryDao,
    required TagDao tagDao,
    required TransactionDao transactionDao,
    required TransactionTagsDao transactionTagsDao,
    required CreditCardDao creditCardDao,
    required CreditDao creditDao,
    required DebtDao debtDao,
    required BudgetDao budgetDao,
    required BudgetInstanceDao budgetInstanceDao,
    required SavingGoalDao savingGoalDao,
    required UpcomingPaymentsDao upcomingPaymentsDao,
    required PaymentRemindersDao paymentRemindersDao,
    required AccountRemoteDataSource accountRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required TagRemoteDataSource tagRemoteDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required TransactionTagRemoteDataSource transactionTagRemoteDataSource,
    required CreditCardRemoteDataSource creditCardRemoteDataSource,
    required CreditRemoteDataSource creditRemoteDataSource,
    required DebtRemoteDataSource debtRemoteDataSource,
    required BudgetRemoteDataSource budgetRemoteDataSource,
    required BudgetInstanceRemoteDataSource budgetInstanceRemoteDataSource,
    required SavingGoalRemoteDataSource savingGoalRemoteDataSource,
    required UpcomingPaymentRemoteDataSource upcomingPaymentRemoteDataSource,
    required PaymentReminderRemoteDataSource paymentReminderRemoteDataSource,
    required ProfileDao profileDao,
    required ProfileRemoteDataSource profileRemoteDataSource,
    required FirebaseFirestore firestore,
    required LoggerService loggerService,
    required AnalyticsService analyticsService,
    required SyncDataSanitizer dataSanitizer,
    OutboxPayloadNormalizer payloadNormalizer = const OutboxPayloadNormalizer(),
  }) : _database = database,
       _outboxDao = outboxDao,
       _accountDao = accountDao,
       _categoryDao = categoryDao,
       _tagDao = tagDao,
       _transactionDao = transactionDao,
       _transactionTagsDao = transactionTagsDao,
       _creditCardDao = creditCardDao,
       _creditDao = creditDao,
       _debtDao = debtDao,
       _budgetDao = budgetDao,
       _budgetInstanceDao = budgetInstanceDao,
       _savingGoalDao = savingGoalDao,
       _upcomingPaymentsDao = upcomingPaymentsDao,
       _paymentRemindersDao = paymentRemindersDao,
       _profileDao = profileDao,
       _accountRemoteDataSource = accountRemoteDataSource,
       _categoryRemoteDataSource = categoryRemoteDataSource,
       _tagRemoteDataSource = tagRemoteDataSource,
       _transactionRemoteDataSource = transactionRemoteDataSource,
       _transactionTagRemoteDataSource = transactionTagRemoteDataSource,
       _creditCardRemoteDataSource = creditCardRemoteDataSource,
       _creditRemoteDataSource = creditRemoteDataSource,
       _debtRemoteDataSource = debtRemoteDataSource,
       _budgetRemoteDataSource = budgetRemoteDataSource,
       _budgetInstanceRemoteDataSource = budgetInstanceRemoteDataSource,
       _savingGoalRemoteDataSource = savingGoalRemoteDataSource,
       _upcomingPaymentRemoteDataSource = upcomingPaymentRemoteDataSource,
       _paymentReminderRemoteDataSource = paymentReminderRemoteDataSource,
       _profileRemoteDataSource = profileRemoteDataSource,
       _firestore = firestore,
       _logger = loggerService,
       _analyticsService = analyticsService,
       _dataSanitizer = dataSanitizer,
       _payloadNormalizer = payloadNormalizer;

  static const int _outboxBatchSize = 500;

  final AppDatabase _database;
  final OutboxDao _outboxDao;
  final AccountDao _accountDao;
  final CategoryDao _categoryDao;
  final TagDao _tagDao;
  final TransactionDao _transactionDao;
  final TransactionTagsDao _transactionTagsDao;
  final CreditCardDao _creditCardDao;
  final CreditDao _creditDao;
  final DebtDao _debtDao;
  final BudgetDao _budgetDao;
  final BudgetInstanceDao _budgetInstanceDao;
  final SavingGoalDao _savingGoalDao;
  final UpcomingPaymentsDao _upcomingPaymentsDao;
  final PaymentRemindersDao _paymentRemindersDao;
  final AccountRemoteDataSource _accountRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final TagRemoteDataSource _tagRemoteDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final TransactionTagRemoteDataSource _transactionTagRemoteDataSource;
  final CreditCardRemoteDataSource _creditCardRemoteDataSource;
  final CreditRemoteDataSource _creditRemoteDataSource;
  final DebtRemoteDataSource _debtRemoteDataSource;
  final BudgetRemoteDataSource _budgetRemoteDataSource;
  final BudgetInstanceRemoteDataSource _budgetInstanceRemoteDataSource;
  final SavingGoalRemoteDataSource _savingGoalRemoteDataSource;
  final UpcomingPaymentRemoteDataSource _upcomingPaymentRemoteDataSource;
  final PaymentReminderRemoteDataSource _paymentReminderRemoteDataSource;
  final ProfileDao _profileDao;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final FirebaseFirestore _firestore;
  final LoggerService _logger;
  final AnalyticsService _analyticsService;
  final OutboxPayloadNormalizer _payloadNormalizer;
  final SyncDataSanitizer _dataSanitizer;

  bool _inProgress = false;

  Future<void> synchronizeOnLogin({
    required AuthUser user,
    AuthUser? previousUser,
  }) async {
    if (_inProgress) {
      _logger.logInfo('AuthSyncService: synchronization already running, skip');
      return;
    }
    if (user.isAnonymous) {
      _logger.logInfo(
        'AuthSyncService: skip sync for anonymous user ${user.uid}.',
      );
      return;
    }

    _inProgress = true;
    final bool upgradingFromAnonymous =
        (previousUser?.isAnonymous ?? false) && !user.isAnonymous;

    final Map<String, dynamic> syncContext = <String, dynamic>{
      'userId': user.uid,
      'upgradedFromAnonymous': upgradingFromAnonymous ? 1 : 0,
    };

    await _analyticsService.logEvent('auth_sync_start', syncContext);
    _logger.logInfo(
      'AuthSyncService: starting login sync for ${user.uid}, upgraded: $upgradingFromAnonymous.',
    );

    List<db.OutboxEntryRow> preparedEntries = <db.OutboxEntryRow>[];
    try {
      preparedEntries = await _preparePendingEntries();
      await _applyOutboxToFirestore(user.uid, preparedEntries);
      final _RemoteSnapshot remoteSnapshot = await _fetchRemoteSnapshot(
        user.uid,
      );
      await _persistMergedState(
        remoteSnapshot: remoteSnapshot,
        processedEntries: preparedEntries,
        user: user,
      );
      await _analyticsService.logEvent('auth_sync_success', <String, dynamic>{
        ...syncContext,
        'pendingEntries': preparedEntries.length,
        'remoteAccounts': remoteSnapshot.accounts.length,
        'remoteCategories': remoteSnapshot.categories.length,
        'remoteTransactions': remoteSnapshot.transactions.length,
        'remoteCredits': remoteSnapshot.credits.length,
        'remoteCreditCards': remoteSnapshot.creditCards.length,
        'remoteDebts': remoteSnapshot.debts.length,
        'remoteBudgets': remoteSnapshot.budgets.length,
        'remoteBudgetInstances': remoteSnapshot.budgetInstances.length,
        'remoteSavingGoals': remoteSnapshot.savingGoals.length,
        'remoteRecurringPayments': remoteSnapshot.upcomingPayments.length,
      });
      _logger.logInfo(
        'AuthSyncService: login sync completed for ${user.uid}. '
        'Accounts: ${remoteSnapshot.accounts.length}, '
        'Categories: ${remoteSnapshot.categories.length}, '
        'Transactions: ${remoteSnapshot.transactions.length}, '
        'Credits: ${remoteSnapshot.credits.length}, '
        'Credit cards: ${remoteSnapshot.creditCards.length}, '
        'Debts: ${remoteSnapshot.debts.length}, '
        'Budgets: ${remoteSnapshot.budgets.length}, '
        'Savings goals: ${remoteSnapshot.savingGoals.length}, '
        'Recurring payments: ${remoteSnapshot.upcomingPayments.length}.',
      );
    } catch (error, stackTrace) {
      _logger.logError(
        'AuthSyncService: synchronization failed for ${user.uid}',
        error,
      );
      // ignore: avoid_print
      print('CRITICAL SYNC ERROR: $error');
      // ignore: avoid_print
      print(stackTrace);
      _analyticsService.reportError(error, stackTrace);
      await _outboxDao.resetAllToPending(
        preparedEntries.map((OutboxEntryRow entry) => entry.id),
      );
      throw const AuthFailure(
        code: 'sync-failed',
        message: 'Failed to synchronize data. Please try again later.',
      );
    } finally {
      _inProgress = false;
    }
  }

  Future<List<db.OutboxEntryRow>> _preparePendingEntries() async {
    return _database.transaction(() async {
      final List<OutboxEntryRow> pending = await _outboxDao.fetchPending(
        limit: _outboxBatchSize,
      );
      final List<OutboxEntryRow> prepared = <db.OutboxEntryRow>[];
      for (final OutboxEntryRow entry in pending) {
        prepared.add(await _outboxDao.prepareForSend(entry));
      }
      return prepared;
    });
  }

  Future<void> _applyOutboxToFirestore(
    String userId,
    List<db.OutboxEntryRow> entries,
  ) async {
    if (entries.isEmpty) return;

    await _firestore.runTransaction((Transaction transaction) async {
      for (final OutboxEntryRow entry in entries) {
        final Map<String, dynamic> payload = _payloadNormalizer.normalize(
          entry.entityType,
          _outboxDao.decodePayload(entry),
        );
        final OutboxOperation operation = OutboxOperation.values.byName(
          entry.operation,
        );
        switch (entry.entityType) {
          case 'account':
            final AccountEntity account = _applyAccountMoney(
              AccountEntity.fromJson(payload),
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _accountRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                account,
              );
            } else {
              _accountRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                account,
              );
            }
            break;
          case 'category':
            final Category category = Category.fromJson(payload);
            if (operation == OutboxOperation.delete) {
              _categoryRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                category,
              );
            } else {
              _categoryRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                category,
              );
            }
            break;
          case 'tag':
            final TagEntity tag = TagEntity.fromJson(payload);
            if (operation == OutboxOperation.delete) {
              _tagRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                tag,
              );
            } else {
              _tagRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                tag,
              );
            }
            break;
          case 'transaction':
            final TransactionEntity transactionEntity =
                _applyTransactionMoney(
                  TransactionEntity.fromJson(payload),
                  payload,
                );
            if (operation == OutboxOperation.delete) {
              _transactionRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                transactionEntity,
              );
            } else {
              _transactionRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                transactionEntity,
              );
            }
            break;
          case 'transaction_tag':
            final TransactionTagEntity link = TransactionTagEntity.fromJson(
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _transactionTagRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                link,
              );
            } else {
              _transactionTagRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                link,
              );
            }
            break;
          case 'credit':
            final CreditEntity credit = _applyCreditMoney(
              CreditEntity.fromJson(payload),
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _creditRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                credit,
              );
            } else {
              _creditRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                credit,
              );
            }
            break;
          case 'credit_card':
            final CreditCardEntity creditCard = _applyCreditCardMoney(
              CreditCardEntity.fromJson(payload),
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _creditCardRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                creditCard,
              );
            } else {
              _creditCardRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                creditCard,
              );
            }
            break;
          case 'debt':
            final DebtEntity debt = _applyDebtMoney(
              DebtEntity.fromJson(payload),
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _debtRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                debt,
              );
            } else {
              _debtRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                debt,
              );
            }
            break;
          case 'profile':
            if (operation == OutboxOperation.delete) {
              continue;
            }
            final Profile profile = Profile.fromJson(payload);
            _profileRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              profile,
            );
            break;
          case 'budget':
            final Budget budget = _applyBudgetMoney(
              Budget.fromJson(payload),
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _budgetRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                budget,
              );
            } else {
              _budgetRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                budget,
              );
            }
            break;
          case 'budget_instance':
            final BudgetInstance instance = _applyBudgetInstanceMoney(
              BudgetInstance.fromJson(payload),
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _budgetInstanceRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                instance,
              );
            } else {
              _budgetInstanceRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                instance,
              );
            }
            break;
          case 'saving_goal':
            final SavingGoal goal = SavingGoal.fromJson(payload);
            _savingGoalRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              goal,
            );
            break;
          case 'upcoming_payment':
            final UpcomingPayment payment = _applyUpcomingPaymentMoney(
              UpcomingPayment.fromJson(payload),
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _upcomingPaymentRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                payment,
              );
            } else {
              _upcomingPaymentRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                payment,
              );
            }
            break;
          case 'payment_reminder':
            final PaymentReminder reminder = _applyPaymentReminderMoney(
              PaymentReminder.fromJson(payload),
              payload,
            );
            if (operation == OutboxOperation.delete) {
              _paymentReminderRemoteDataSource.deleteInTransaction(
                transaction,
                userId,
                reminder,
              );
            } else {
              _paymentReminderRemoteDataSource.upsertInTransaction(
                transaction,
                userId,
                reminder,
              );
            }
            break;
          default:
            throw UnsupportedError(
              'Unsupported outbox entity type ${entry.entityType}',
            );
        }
      }
    });
  }

  AccountEntity _applyAccountMoney(
    AccountEntity account,
    Map<String, dynamic> payload,
  ) {
    return account.copyWith(
      balanceMinor: _readBigInt(payload['balanceMinor']),
      openingBalanceMinor: _readBigInt(payload['openingBalanceMinor']),
      currencyScale: _readInt(payload['currencyScale']),
    );
  }

  TransactionEntity _applyTransactionMoney(
    TransactionEntity transaction,
    Map<String, dynamic> payload,
  ) {
    return transaction.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  CreditEntity _applyCreditMoney(
    CreditEntity credit,
    Map<String, dynamic> payload,
  ) {
    return credit.copyWith(
      totalAmountMinor: _readBigInt(payload['totalAmountMinor']),
      totalAmountScale: _readInt(payload['totalAmountScale']),
    );
  }

  CreditCardEntity _applyCreditCardMoney(
    CreditCardEntity creditCard,
    Map<String, dynamic> payload,
  ) {
    return creditCard.copyWith(
      creditLimitMinor: _readBigInt(payload['creditLimitMinor']),
      creditLimitScale: _readInt(payload['creditLimitScale']),
    );
  }

  DebtEntity _applyDebtMoney(DebtEntity debt, Map<String, dynamic> payload) {
    return debt.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  Budget _applyBudgetMoney(Budget budget, Map<String, dynamic> payload) {
    return budget.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  BudgetInstance _applyBudgetInstanceMoney(
    BudgetInstance instance,
    Map<String, dynamic> payload,
  ) {
    return instance.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      spentMinor: _readBigInt(payload['spentMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  UpcomingPayment _applyUpcomingPaymentMoney(
    UpcomingPayment payment,
    Map<String, dynamic> payload,
  ) {
    return payment.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  PaymentReminder _applyPaymentReminderMoney(
    PaymentReminder reminder,
    Map<String, dynamic> payload,
  ) {
    return reminder.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  BigInt? _readBigInt(Object? value) {
    if (value == null) return null;
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is num) return BigInt.from(value.toInt());
    return BigInt.tryParse(value.toString());
  }

  int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<_RemoteSnapshot> _fetchRemoteSnapshot(String userId) async {
    final List<List<Object>> results = await Future.wait(<Future<List<Object>>>[
      _accountRemoteDataSource.fetchAll(userId),
      _categoryRemoteDataSource.fetchAll(userId),
      _tagRemoteDataSource.fetchAll(userId),
      _transactionRemoteDataSource.fetchAll(userId),
      _transactionTagRemoteDataSource.fetchAll(userId),
      _creditRemoteDataSource.fetchAll(userId),
      _creditCardRemoteDataSource.fetchAll(userId),
      _debtRemoteDataSource.fetchAll(userId),
      _budgetRemoteDataSource.fetchAll(userId),
      _budgetInstanceRemoteDataSource.fetchAll(userId),
      _savingGoalRemoteDataSource.fetchAll(userId),
      _upcomingPaymentRemoteDataSource.fetchAll(userId),
      _paymentReminderRemoteDataSource.fetchAll(userId),
    ]);
    final Profile? profile = await _profileRemoteDataSource.fetch(userId);
    return _RemoteSnapshot(
      accounts: results[0] as List<AccountEntity>,
      categories: results[1] as List<Category>,
      tags: results[2] as List<TagEntity>,
      transactions: results[3] as List<TransactionEntity>,
      transactionTags: results[4] as List<TransactionTagEntity>,
      credits: results[5] as List<CreditEntity>,
      creditCards: results[6] as List<CreditCardEntity>,
      debts: results[7] as List<DebtEntity>,
      budgets: results[8] as List<Budget>,
      budgetInstances: results[9] as List<BudgetInstance>,
      savingGoals: results[10] as List<SavingGoal>,
      upcomingPayments: results[11] as List<UpcomingPayment>,
      paymentReminders: results[12] as List<PaymentReminder>,
      profile: profile,
    );
  }

  Future<void> _persistMergedState({
    required _RemoteSnapshot remoteSnapshot,
    required List<db.OutboxEntryRow> processedEntries,
    required AuthUser user,
  }) async {
    final String userId = user.uid;
    final List<int> processedIds = processedEntries
        .map((OutboxEntryRow entry) => entry.id)
        .toList();
    await _database.transaction(() async {
      if (processedIds.isNotEmpty) {
        await _outboxDao.markBatchAsSent(processedIds);
        await _outboxDao.clearSent();
      }

      final List<AccountEntity> localAccounts = await _accountDao
          .getAllAccounts();
      final List<Category> localCategories = await _categoryDao
          .getAllCategories();
      final List<TagEntity> localTags = await _tagDao.getAllTags();
      final List<TransactionEntity> localTransactions = await _transactionDao
          .getAllTransactions();
      final List<TransactionTagEntity> localTransactionTags =
          (await _transactionTagsDao.getAllTransactionTags())
              .map(_transactionTagsDao.mapRowToEntity)
              .toList();
      final List<CreditEntity> localCredits = (await _creditDao.getAllCredits())
          .map(_creditDao.mapRowToEntity)
          .toList();
      final List<CreditCardEntity> localCreditCards =
          (await _creditCardDao.getAllCreditCards())
              .map(_creditCardDao.mapRowToEntity)
              .toList();
      final List<DebtEntity> localDebts = (await _debtDao.getAllDebts())
          .map(_debtDao.mapRowToEntity)
          .toList();
      final List<Budget> localBudgets = await _budgetDao.getAllBudgets();
      final List<BudgetInstance> localBudgetInstances = await _budgetInstanceDao
          .getAllInstances();
      final List<SavingGoal> localSavingGoals = await _savingGoalDao.getGoals(
        includeArchived: true,
      );
      final List<UpcomingPayment> localUpcomingPayments =
          await _upcomingPaymentsDao.getAll();
      final List<PaymentReminder> localPaymentReminders =
          await _paymentRemindersDao.getAll();

      final List<AccountEntity> mergedAccounts = _mergeEntities<AccountEntity>(
        local: localAccounts,
        remote: remoteSnapshot.accounts,
        getId: (AccountEntity entity) => entity.id,
        getUpdatedAt: (AccountEntity entity) => entity.updatedAt,
      );
      final List<Category> mergedCategories = _mergeEntities<Category>(
        local: localCategories,
        remote: remoteSnapshot.categories,
        getId: (Category entity) => entity.id,
        getUpdatedAt: (Category entity) => entity.updatedAt,
      );
      final List<TagEntity> mergedTags = _mergeEntities<TagEntity>(
        local: localTags,
        remote: remoteSnapshot.tags,
        getId: (TagEntity entity) => entity.id,
        getUpdatedAt: (TagEntity entity) => entity.updatedAt,
      );
      final _CategorySanitizationResult sanitizedCategories =
          _sanitizeCategories(mergedCategories);
      final List<Category> normalizedCategories =
          sanitizedCategories.categories;
      final Map<String, String> categoryIdMapping =
          sanitizedCategories.idMapping;

      final List<TransactionEntity> mergedTransactions =
          _mergeEntities<TransactionEntity>(
            local: localTransactions,
            remote: remoteSnapshot.transactions,
            getId: (TransactionEntity entity) => entity.id,
            getUpdatedAt: (TransactionEntity entity) => entity.updatedAt,
          );
      final List<TransactionTagEntity> mergedTransactionTags =
          _mergeEntities<TransactionTagEntity>(
            local: localTransactionTags,
            remote: remoteSnapshot.transactionTags,
            getId: _transactionTagKey,
            getUpdatedAt: (TransactionTagEntity entity) => entity.updatedAt,
          );
      final List<TransactionEntity> normalizedTransactions =
          _normalizeTransactions(mergedTransactions, categoryIdMapping);
      final List<CreditEntity> mergedCredits = _mergeEntities<CreditEntity>(
        local: localCredits,
        remote: remoteSnapshot.credits,
        getId: (CreditEntity entity) => entity.id,
        getUpdatedAt: (CreditEntity entity) => entity.updatedAt,
      );
      final List<CreditCardEntity> mergedCreditCards =
          _mergeEntities<CreditCardEntity>(
            local: localCreditCards,
            remote: remoteSnapshot.creditCards,
            getId: (CreditCardEntity entity) => entity.id,
            getUpdatedAt: (CreditCardEntity entity) => entity.updatedAt,
          );
      final List<DebtEntity> mergedDebts = _mergeEntities<DebtEntity>(
        local: localDebts,
        remote: remoteSnapshot.debts,
        getId: (DebtEntity entity) => entity.id,
        getUpdatedAt: (DebtEntity entity) => entity.updatedAt,
      );
      final List<Budget> mergedBudgets = _mergeEntities<Budget>(
        local: localBudgets,
        remote: remoteSnapshot.budgets,
        getId: (Budget entity) => entity.id,
        getUpdatedAt: (Budget entity) => entity.updatedAt,
      );
      final List<Budget> normalizedBudgets = _normalizeBudgets(
        mergedBudgets,
        categoryIdMapping,
      );
      final List<BudgetInstance> mergedBudgetInstances =
          _mergeEntities<BudgetInstance>(
            local: localBudgetInstances,
            remote: remoteSnapshot.budgetInstances,
            getId: (BudgetInstance entity) => entity.id,
            getUpdatedAt: (BudgetInstance entity) => entity.updatedAt,
          );
      final List<SavingGoal> mergedSavingGoals = _mergeEntities<SavingGoal>(
        local: localSavingGoals,
        remote: remoteSnapshot.savingGoals,
        getId: (SavingGoal goal) => goal.id,
        getUpdatedAt: (SavingGoal goal) => goal.updatedAt,
      );
      final List<UpcomingPayment> mergedUpcomingPayments =
          _mergeEntities<UpcomingPayment>(
            local: localUpcomingPayments,
            remote: remoteSnapshot.upcomingPayments,
            getId: (UpcomingPayment payment) => payment.id,
            getUpdatedAt: (UpcomingPayment payment) =>
                DateTime.fromMillisecondsSinceEpoch(payment.updatedAtMs),
          );
      final List<PaymentReminder> mergedPaymentReminders =
          _mergeEntities<PaymentReminder>(
            local: localPaymentReminders,
            remote: remoteSnapshot.paymentReminders,
            getId: (PaymentReminder reminder) => reminder.id,
            getUpdatedAt: (PaymentReminder reminder) =>
                DateTime.fromMillisecondsSinceEpoch(reminder.updatedAtMs),
          );

      final Profile? mergedProfile = _mergeProfile(
        await _profileDao.getProfile(userId),
        remoteSnapshot.profile,
      );

      // --- Tiered Insertion Strategy ---

      await _database.transaction(() async {
        // Tier 1: Base Entities (Accounts, Categories, Tags)
        await _accountDao.upsertAll(mergedAccounts);
        await _categoryDao.upsertAll(normalizedCategories);
        await _tagDao.upsertAll(mergedTags);

        final Set<String> validAccountIds = mergedAccounts
            .map((AccountEntity e) => e.id)
            .toSet();
        final Set<String> validCategoryIds = normalizedCategories
            .map((Category e) => e.id)
            .toSet();
        final Set<String> validTagIds = mergedTags
            .map((TagEntity e) => e.id)
            .toSet();

        // Tier 2: Dependent Entities - Goals
        final List<CreditEntity> sanitizedCredits = _dataSanitizer
            .sanitizeCredits(
              credits: mergedCredits,
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
            );
        await _creditDao.upsertAll(sanitizedCredits);

        final List<CreditCardEntity> sanitizedCreditCards = _dataSanitizer
            .sanitizeCreditCards(
              creditCards: mergedCreditCards,
              validAccountIds: validAccountIds,
            );
        await _creditCardDao.upsertAll(sanitizedCreditCards);

        final List<DebtEntity> sanitizedDebts = _dataSanitizer.sanitizeDebts(
          debts: mergedDebts,
          validAccountIds: validAccountIds,
        );
        await _debtDao.upsertAll(sanitizedDebts);

        await _savingGoalDao.upsertAll(mergedSavingGoals);
        final Set<String> validSavingGoalIds = mergedSavingGoals
            .map((SavingGoal e) => e.id)
            .toSet();

        // Tier 3: Core Entities (Transactions, Rules, Budgets)
        // Sanitize transactions
        final List<TransactionEntity> sanitizedTransactions = _dataSanitizer
            .sanitizeTransactions(
              transactions: normalizedTransactions,
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
              validSavingGoalIds: validSavingGoalIds,
            );

        final List<UpcomingPayment> sanitizedUpcomingPayments = _dataSanitizer
            .sanitizeUpcomingPayments(
              payments: mergedUpcomingPayments,
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
            );

        await _transactionDao.upsertAll(sanitizedTransactions);
        final List<AccountEntity> recalculatedAccounts =
            await _recalculateBalances(
          accounts: mergedAccounts,
          transactions: sanitizedTransactions,
        );
        await _accountDao.upsertAll(recalculatedAccounts);

        final Set<String> validTransactionIds = sanitizedTransactions
            .map((TransactionEntity e) => e.id)
            .toSet();
        final List<TransactionTagEntity> sanitizedTransactionTags =
            _dataSanitizer.sanitizeTransactionTags(
              transactionTags: mergedTransactionTags,
              validTransactionIds: validTransactionIds,
              validTagIds: validTagIds,
            );
        await _transactionTagsDao.upsertAll(sanitizedTransactionTags);

        for (final UpcomingPayment payment in sanitizedUpcomingPayments) {
          await _upcomingPaymentsDao.upsert(payment);
        }
        for (final PaymentReminder reminder in mergedPaymentReminders) {
          await _paymentRemindersDao.upsert(reminder);
        }

        await _budgetDao.upsertAll(normalizedBudgets);
        final Set<String> validBudgetIds = normalizedBudgets
            .map((Budget e) => e.id)
            .toSet();

        // Tier 4: Strongly Dependent Entities (Budget Instances)
        // Sanitize budget instances
        final List<BudgetInstance> sanitizedBudgetInstances = _dataSanitizer
            .sanitizeBudgetInstances(
              instances: mergedBudgetInstances,
              validBudgetIds: validBudgetIds,
            );

        await _budgetInstanceDao.upsertAll(sanitizedBudgetInstances);

        // Upsert profile last (least dependent, mostly meta)
        if (mergedProfile != null) {
          await _profileDao.upsert(mergedProfile);
        }
      });
      final Profile? profile = _mergeProfile(
        await _profileDao.getProfile(userId),
        remoteSnapshot.profile,
      );

      // If profile is missing or is a fallback profile, initialize it with user data
      if (profile == null || profile.updatedAt.millisecondsSinceEpoch == 0) {
        final String systemLocale = kIsWeb
            ? Intl.systemLocale.split('_').first
            : Platform.localeName.split('_').first;
        final Profile newProfile =
            (profile ?? Profile(uid: userId, updatedAt: DateTime.now().toUtc()))
                .copyWith(
                  name: user.displayName ?? '',
                  locale: systemLocale,
                  updatedAt: DateTime.now().toUtc(),
                );
        await _profileDao.upsertInTransaction(newProfile);

        // Also queue an update to sync this new profile to remote
        await _outboxDao.enqueue(
          entityType: 'profile',
          entityId: userId,
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{
            'uid': newProfile.uid,
            'name': newProfile.name,
            'currency': newProfile.currency.name,
            'locale': newProfile.locale,
            'photoUrl': newProfile.photoUrl,
            'updatedAt': newProfile.updatedAt.toIso8601String(),
          },
        );
      } else if (profile != null) {
        await _profileDao.upsertInTransaction(profile);
      }
    });
  }

  Future<List<AccountEntity>> _recalculateBalances({
    required List<AccountEntity> accounts,
    required List<TransactionEntity> transactions,
  }) async {
    final Map<String, MoneyAccumulator> deltas =
        <String, MoneyAccumulator>{};
    final List<db.CreditRow> creditRows = await _creditDao.getAllCredits();
    final Map<String, String> creditAccountByCategoryId = <String, String>{
      for (final db.CreditRow row in creditRows)
        if (row.categoryId != null) row.categoryId!: row.accountId,
    };

    for (final TransactionEntity transaction in transactions) {
      if (transaction.isDeleted) continue;
      final String? creditAccountId = transaction.categoryId != null
          ? creditAccountByCategoryId[transaction.categoryId!]
          : null;
      final TransactionType type = parseTransactionType(transaction.type);
      final MoneyAmount amount = transaction.amountValue.abs();

      if (type.isTransfer) {
        final String? targetId = transaction.transferAccountId;
        if (targetId == null || targetId == transaction.accountId) {
          continue;
        }
        _applyMoneyDelta(
          deltas,
          transaction.accountId,
          _negateMoneyAmount(amount),
        );
        _applyMoneyDelta(deltas, targetId, amount);
        continue;
      }

      if (creditAccountId != null) {
        final MoneyAmount repaymentDelta = type.isExpense
            ? amount
            : _negateMoneyAmount(amount);
        if (transaction.accountId != creditAccountId) {
          final MoneyAmount accountDelta = type.isIncome
              ? amount
              : _negateMoneyAmount(amount);
          _applyMoneyDelta(deltas, transaction.accountId, accountDelta);
          _applyMoneyDelta(deltas, creditAccountId, repaymentDelta);
        } else {
          _applyMoneyDelta(deltas, creditAccountId, repaymentDelta);
        }
        continue;
      }

      final MoneyAmount delta = type.isIncome
          ? amount
          : _negateMoneyAmount(amount);
      _applyMoneyDelta(deltas, transaction.accountId, delta);
    }

    return accounts
        .map(
          (AccountEntity account) {
            final int scale = account.currencyScale ??
                resolveCurrencyScale(account.currency);
            final MoneyAmount netAmount = _normalizeAccumulator(
              deltas[account.id],
              scale,
            );
            final BigInt openingBalanceMinor = _resolveOpeningBalanceMinor(
              account: account,
              scale: scale,
            );
            final BigInt balanceMinor = openingBalanceMinor + netAmount.minor;
            return account.copyWith(
              openingBalanceMinor: openingBalanceMinor,
              balanceMinor: balanceMinor,
              currencyScale: scale,
            );
          },
        )
        .toList(growable: false);
  }

  BigInt _resolveOpeningBalanceMinor({
    required AccountEntity account,
    required int scale,
  }) {
    final BigInt existing = account.openingBalanceMinor ?? BigInt.zero;
    final int existingScale = account.currencyScale ?? scale;
    return _convertMinorScale(existing, existingScale, scale);
  }

  void _applyMoneyDelta(
    Map<String, MoneyAccumulator> deltas,
    String accountId,
    MoneyAmount amount,
  ) {
    final MoneyAccumulator accumulator =
        deltas.putIfAbsent(accountId, MoneyAccumulator.new);
    accumulator.add(amount);
  }

  MoneyAmount _normalizeAccumulator(
    MoneyAccumulator? accumulator,
    int targetScale,
  ) {
    if (accumulator == null || accumulator.minor == BigInt.zero) {
      return MoneyAmount(minor: BigInt.zero, scale: targetScale);
    }
    final int sourceScale = accumulator.scale;
    final BigInt minor = _convertMinorScale(
      accumulator.minor,
      sourceScale,
      targetScale,
    );
    return MoneyAmount(minor: minor, scale: targetScale);
  }

  BigInt _convertMinorScale(
    BigInt minor,
    int fromScale,
    int toScale,
  ) {
    if (fromScale == toScale) {
      return minor;
    }
    final Money source = Money(
      minor: minor,
      currency: 'XXX',
      scale: fromScale,
    );
    return Money.fromDecimalString(
      source.toDecimalString(),
      currency: 'XXX',
      scale: toScale,
    ).minor;
  }

  MoneyAmount _negateMoneyAmount(MoneyAmount amount) {
    return MoneyAmount(minor: -amount.minor, scale: amount.scale);
  }

  String _transactionTagKey(TransactionTagEntity link) {
    return '${link.transactionId}::${link.tagId}';
  }

  List<T> _mergeEntities<T>({
    required List<T> local,
    required List<T> remote,
    required String Function(T) getId,
    required DateTime Function(T) getUpdatedAt,
  }) {
    final Map<String, T> merged = <String, T>{
      for (final T item in local) getId(item): item,
    };

    for (final T remoteItem in remote) {
      final String key = getId(remoteItem);
      final T? existing = merged[key];
      if (existing == null) {
        merged[key] = remoteItem;
        continue;
      }
      final DateTime existingUpdatedAt = getUpdatedAt(existing);
      final DateTime remoteUpdatedAt = getUpdatedAt(remoteItem);
      if (!existingUpdatedAt.isAfter(remoteUpdatedAt)) {
        merged[key] = remoteItem;
      }
    }

    return merged.values.toList();
  }

  Profile? _mergeProfile(Profile? local, Profile? remote) {
    if (local == null) {
      return remote;
    }
    if (remote == null) {
      return local;
    }
    return local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
  }

  _CategorySanitizationResult _sanitizeCategories(List<Category> categories) {
    if (categories.isEmpty) {
      return const _CategorySanitizationResult(
        categories: <Category>[],
        idMapping: <String, String>{},
      );
    }

    final Map<String, List<Category>> groupedByName =
        <String, List<Category>>{};
    for (final Category category in categories) {
      final String key = category.name.trim().toLowerCase();
      groupedByName.putIfAbsent(key, () => <Category>[]).add(category);
    }

    final Map<String, String> idMapping = <String, String>{};
    final List<Category> sanitized = <Category>[];
    final Set<String> deduplicatedNames = <String>{};

    for (final List<Category> group in groupedByName.values) {
      if (group.isEmpty) {
        continue;
      }
      group.sort((Category a, Category b) {
        final int deletionComparison = (a.isDeleted ? 1 : 0).compareTo(
          b.isDeleted ? 1 : 0,
        );
        if (deletionComparison != 0) {
          return deletionComparison;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });

      final Category canonical = group.first;
      sanitized.add(canonical);
      for (final Category item in group) {
        idMapping[item.id] = canonical.id;
      }

      if (group.length > 1) {
        deduplicatedNames.add(canonical.name);
      }
    }

    if (deduplicatedNames.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: deduplicated categories with identical names: '
        '${deduplicatedNames.join(', ')}.',
      );
    }

    final List<Category> normalized = _normalizeCategoryParents(
      sanitized,
      idMapping,
    );
    // Sort topologically to ensure parents are inserted before children
    normalized.sort((Category a, Category b) {
      if (a.parentId == b.id) return 1; // a depends on b, so b comes first
      if (b.parentId == a.id) return -1; // b depends on a, so a comes first
      // If no direct dependency, sort by depth (parents have null parentId)
      if (a.parentId == null && b.parentId != null) return -1;
      if (b.parentId == null && a.parentId != null) return 1;
      return a.name.compareTo(b.name);
    });
    return _CategorySanitizationResult(
      categories: normalized,
      idMapping: idMapping,
    );
  }

  List<Category> _normalizeCategoryParents(
    List<Category> categories,
    Map<String, String> idMapping,
  ) {
    if (categories.isEmpty || idMapping.isEmpty) {
      return categories;
    }

    final Map<String, int> cleared = <String, int>{};
    final Map<String, int> remapped = <String, int>{};
    final List<Category> normalized = <Category>[];

    for (final Category category in categories) {
      final String? parentId = category.parentId;
      if (parentId == null) {
        normalized.add(category);
        continue;
      }

      final String? canonicalParentId = idMapping[parentId];
      if (canonicalParentId == null || canonicalParentId == category.id) {
        cleared[parentId] = (cleared[parentId] ?? 0) + 1;
        normalized.add(category.copyWith(parentId: null));
        continue;
      }

      if (canonicalParentId != parentId) {
        remapped[canonicalParentId] = (remapped[canonicalParentId] ?? 0) + 1;
        normalized.add(category.copyWith(parentId: canonicalParentId));
        continue;
      }

      normalized.add(category);
    }

    if (cleared.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: removed parent assignments for categories due to '
        'missing canonical references: ${_formatIdCounts(cleared)}.',
      );
    }
    if (remapped.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: remapped category parent references to canonical IDs: '
        '${_formatIdCounts(remapped)}.',
      );
    }

    return normalized;
  }

  List<TransactionEntity> _normalizeTransactions(
    List<TransactionEntity> transactions,
    Map<String, String> categoryIdMapping,
  ) {
    if (transactions.isEmpty || categoryIdMapping.isEmpty) {
      return transactions;
    }

    final Map<String, int> cleared = <String, int>{};
    final Map<String, int> remapped = <String, int>{};
    final List<TransactionEntity> normalized = <TransactionEntity>[];

    for (final TransactionEntity transaction in transactions) {
      final String? categoryId = transaction.categoryId;
      if (categoryId == null) {
        normalized.add(transaction);
        continue;
      }

      final String? canonicalId = categoryIdMapping[categoryId];
      if (canonicalId == null) {
        cleared[categoryId] = (cleared[categoryId] ?? 0) + 1;
        normalized.add(transaction.copyWith(categoryId: null));
        continue;
      }

      if (canonicalId != categoryId) {
        remapped[canonicalId] = (remapped[canonicalId] ?? 0) + 1;
        normalized.add(transaction.copyWith(categoryId: canonicalId));
        continue;
      }

      normalized.add(transaction);
    }

    if (cleared.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: removed category assignments for transactions due to '
        'missing categories: ${_formatIdCounts(cleared)}.',
      );
    }
    if (remapped.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: remapped transaction categories to canonical IDs: '
        '${_formatIdCounts(remapped)}.',
      );
    }

    return normalized;
  }

  List<Budget> _normalizeBudgets(
    List<Budget> budgets,
    Map<String, String> categoryIdMapping,
  ) {
    if (budgets.isEmpty || categoryIdMapping.isEmpty) {
      return budgets;
    }

    final Map<String, int> removed = <String, int>{};
    final List<Budget> normalized = <Budget>[];

    for (final Budget budget in budgets) {
      final LinkedHashSet<String> mappedCategories = LinkedHashSet<String>();
      bool changed = false;
      for (final String categoryId in budget.categories) {
        final String? canonicalId = categoryIdMapping[categoryId];
        if (canonicalId == null) {
          removed[categoryId] = (removed[categoryId] ?? 0) + 1;
          changed = true;
          continue;
        }
        if (canonicalId != categoryId) {
          changed = true;
        }
        mappedCategories.add(canonicalId);
      }

      if (!changed &&
          mappedCategories.length == budget.categories.length &&
          _listsEqual(mappedCategories.toList(), budget.categories)) {
        normalized.add(budget);
      } else {
        normalized.add(budget.copyWith(categories: mappedCategories.toList()));
      }
    }

    if (removed.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: removed unknown categories from budgets: '
        '${_formatIdCounts(removed)}.',
      );
    }

    return normalized;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  String _formatIdCounts(Map<String, int> counts) {
    return counts.entries
        .map((MapEntry<String, int> entry) => '${entry.key}(${entry.value})')
        .join(', ');
  }
}

class _CategorySanitizationResult {
  const _CategorySanitizationResult({
    required this.categories,
    required this.idMapping,
  });

  final List<Category> categories;
  final Map<String, String> idMapping;
}

class _RemoteSnapshot {
  _RemoteSnapshot({
    required this.accounts,
    required this.categories,
    required this.tags,
    required this.transactions,
    required this.transactionTags,
    required this.credits,
    required this.creditCards,
    required this.debts,
    required this.budgets,
    required this.budgetInstances,
    required this.savingGoals,
    required this.upcomingPayments,
    required this.paymentReminders,
    required this.profile,
  });

  final List<AccountEntity> accounts;
  final List<Category> categories;
  final List<TagEntity> tags;
  final List<TransactionEntity> transactions;
  final List<TransactionTagEntity> transactionTags;
  final List<CreditEntity> credits;
  final List<CreditCardEntity> creditCards;
  final List<DebtEntity> debts;
  final List<Budget> budgets;
  final List<BudgetInstance> budgetInstances;
  final List<SavingGoal> savingGoals;
  final List<UpcomingPayment> upcomingPayments;
  final List<PaymentReminder> paymentReminders;
  final Profile? profile;
}
