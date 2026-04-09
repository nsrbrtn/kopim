import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/data/services/transaction_balance_helper.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Репозиторий, сохраняющий импортированные данные через Drift DAO.
class ImportDataRepositoryImpl implements ImportDataRepository {
  ImportDataRepositoryImpl({
    required db.AppDatabase database,
    required AccountDao accountDao,
    required CategoryDao categoryDao,
    required TagDao tagDao,
    required TransactionTagsDao transactionTagsDao,
    required CreditDao creditDao,
    required CreditCardDao creditCardDao,
    required DebtDao debtDao,
    required BudgetDao budgetDao,
    required BudgetInstanceDao budgetInstanceDao,
    required SavingGoalDao savingGoalDao,
    required UpcomingPaymentsDao upcomingPaymentsDao,
    required PaymentRemindersDao paymentRemindersDao,
    required TransactionDao transactionDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _accountDao = accountDao,
       _categoryDao = categoryDao,
       _tagDao = tagDao,
       _transactionTagsDao = transactionTagsDao,
       _creditDao = creditDao,
       _creditCardDao = creditCardDao,
       _debtDao = debtDao,
       _budgetDao = budgetDao,
       _budgetInstanceDao = budgetInstanceDao,
       _savingGoalDao = savingGoalDao,
       _upcomingPaymentsDao = upcomingPaymentsDao,
       _paymentRemindersDao = paymentRemindersDao,
       _transactionDao = transactionDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final AccountDao _accountDao;
  final CategoryDao _categoryDao;
  final TagDao _tagDao;
  final TransactionTagsDao _transactionTagsDao;
  final CreditDao _creditDao;
  final CreditCardDao _creditCardDao;
  final DebtDao _debtDao;
  final BudgetDao _budgetDao;
  final BudgetInstanceDao _budgetInstanceDao;
  final SavingGoalDao _savingGoalDao;
  final UpcomingPaymentsDao _upcomingPaymentsDao;
  final PaymentRemindersDao _paymentRemindersDao;
  final TransactionDao _transactionDao;
  final OutboxDao _outboxDao;

  static const String _accountEntityType = 'account';
  static const String _categoryEntityType = 'category';
  static const String _tagEntityType = 'tag';
  static const String _transactionTagEntityType = 'transaction_tag';
  static const String _savingGoalEntityType = 'saving_goal';
  static const String _transactionEntityType = 'transaction';
  static const String _creditEntityType = 'credit';
  static const String _creditCardEntityType = 'credit_card';
  static const String _debtEntityType = 'debt';
  static const String _budgetEntityType = 'budget';
  static const String _budgetInstanceEntityType = 'budget_instance';
  static const String _upcomingPaymentEntityType = 'upcoming_payment';
  static const String _paymentReminderEntityType = 'payment_reminder';

  @override
  Future<void> importData({
    required List<AccountEntity> accounts,
    required List<Category> categories,
    List<TagEntity> tags = const <TagEntity>[],
    List<TransactionTagEntity> transactionTags = const <TransactionTagEntity>[],
    required List<SavingGoal> savingGoals,
    required List<CreditEntity> credits,
    required List<CreditCardEntity> creditCards,
    required List<DebtEntity> debts,
    List<Budget> budgets = const <Budget>[],
    List<BudgetInstance> budgetInstances = const <BudgetInstance>[],
    List<UpcomingPayment> upcomingPayments = const <UpcomingPayment>[],
    List<PaymentReminder> paymentReminders = const <PaymentReminder>[],
    required List<TransactionEntity> transactions,
  }) async {
    await _database.transaction(() async {
      final _ExistingImportSnapshot existingSnapshot =
          await _loadExistingSnapshot();
      await _clearImportedSnapshot();
      await _accountDao.upsertAll(accounts);
      await _categoryDao.upsertAll(categories);
      await _tagDao.upsertAll(tags);
      await _creditDao.upsertAll(credits);
      await _creditCardDao.upsertAll(creditCards);
      await _debtDao.upsertAll(debts);
      await _budgetDao.upsertAll(budgets);
      await _budgetInstanceDao.upsertAll(budgetInstances);
      await _savingGoalDao.upsertAll(savingGoals);
      await _upsertUpcomingPayments(upcomingPayments);
      await _upsertPaymentReminders(paymentReminders);
      await _transactionDao.upsertAll(transactions);
      await _transactionTagsDao.upsertAll(transactionTags);
      await _recalculateAccountBalances(transactions);

      final List<AccountEntity> persistedAccounts = await _loadImportedAccounts(
        accounts,
      );
      final DateTime syncTimestamp = DateTime.now().toUtc();
      await _enqueueDeletedSnapshot(
        existingSnapshot: existingSnapshot,
        importedAccountIds: accounts.map((AccountEntity account) => account.id),
        importedCategoryIds: categories.map((Category category) => category.id),
        importedTagKeys: tags.map((TagEntity tag) => tag.id),
        importedTransactionTagKeys: transactionTags.map(_transactionTagKey),
        importedSavingGoalIds: savingGoals.map((SavingGoal goal) => goal.id),
        importedCreditIds: credits.map((CreditEntity credit) => credit.id),
        importedCreditCardIds: creditCards.map(
          (CreditCardEntity creditCard) => creditCard.id,
        ),
        importedDebtIds: debts.map((DebtEntity debt) => debt.id),
        importedBudgetIds: budgets.map((Budget budget) => budget.id),
        importedBudgetInstanceIds: budgetInstances.map(
          (BudgetInstance instance) => instance.id,
        ),
        importedUpcomingPaymentIds: upcomingPayments.map(
          (UpcomingPayment payment) => payment.id,
        ),
        importedPaymentReminderIds: paymentReminders.map(
          (PaymentReminder reminder) => reminder.id,
        ),
        importedTransactionIds: transactions.map(
          (TransactionEntity transaction) => transaction.id,
        ),
        syncTimestamp: syncTimestamp,
      );
      await _enqueueAccounts(persistedAccounts);
      await _enqueueCategories(categories);
      await _enqueueTags(tags);
      await _enqueueCredits(credits);
      await _enqueueCreditCards(creditCards);
      await _enqueueDebts(debts);
      await _enqueueBudgets(budgets);
      await _enqueueBudgetInstances(budgetInstances);
      await _enqueueSavingGoals(savingGoals);
      await _enqueueUpcomingPayments(upcomingPayments);
      await _enqueuePaymentReminders(paymentReminders);
      await _enqueueTransactions(transactions);
      await _enqueueTransactionTags(transactionTags);
    });
  }

  Future<_ExistingImportSnapshot> _loadExistingSnapshot() async {
    return _ExistingImportSnapshot(
      accounts: await _accountDao.getAllAccounts(),
      categories: await _categoryDao.getAllCategories(),
      tags: await _tagDao.getAllTags(),
      transactionTags: (await _transactionTagsDao.getAllTransactionTags())
          .map(_transactionTagsDao.mapRowToEntity)
          .toList(growable: false),
      savingGoals: await _savingGoalDao.getGoals(includeArchived: true),
      credits: (await _creditDao.getAllCredits())
          .map(_creditDao.mapRowToEntity)
          .toList(growable: false),
      creditCards: (await _creditCardDao.getAllCreditCards())
          .map(_creditCardDao.mapRowToEntity)
          .toList(growable: false),
      debts: (await _debtDao.getAllDebts())
          .map(_debtDao.mapRowToEntity)
          .toList(growable: false),
      budgets: await _budgetDao.getAllBudgets(),
      budgetInstances: await _budgetInstanceDao.getAllInstances(),
      upcomingPayments: await _upcomingPaymentsDao.getAll(),
      paymentReminders: await _paymentRemindersDao.getAllIncludingDone(),
      transactions: await _transactionDao.getAllTransactions(),
    );
  }

  Future<void> _clearImportedSnapshot() async {
    await (_database.delete(_database.goalContributions)).go();
    await (_database.delete(_database.creditPaymentGroups)).go();
    await (_database.delete(_database.creditPaymentSchedules)).go();
    await (_database.delete(_database.paymentReminders)).go();
    await (_database.delete(_database.upcomingPayments)).go();
    await (_database.delete(_database.budgetInstances)).go();
    await (_database.delete(_database.budgets)).go();
    await (_database.delete(_database.debts)).go();
    await (_database.delete(_database.creditCards)).go();
    await (_database.delete(_database.credits)).go();
    await (_database.delete(_database.savingGoals)).go();
    await (_database.delete(_database.transactionTags)).go();
    await (_database.delete(_database.tags)).go();
    await (_database.delete(_database.transactions)).go();
    await (_database.delete(_database.categories)).go();
    await (_database.delete(_database.accounts)).go();
    await (_database.delete(_database.outboxEntries)).go();
  }

  Future<void> _recalculateAccountBalances(
    List<TransactionEntity> transactions,
  ) async {
    final List<AccountEntity> accounts = await _accountDao.getAllAccounts();
    final Map<String, MoneyAmount> deltas = <String, MoneyAmount>{
      for (final AccountEntity account in accounts)
        account.id: MoneyAmount(
          minor: BigInt.zero,
          scale:
              account.currencyScale ?? resolveCurrencyScale(account.currency),
        ),
    };
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
      final Map<String, MoneyAmount> effect = buildTransactionEffect(
        transaction: transaction,
        creditAccountId: creditAccountId,
      );
      applyTransactionEffect(deltas, effect);
    }

    final List<AccountEntity> updatedAccounts = accounts
        .map((AccountEntity account) {
          final int scale =
              account.currencyScale ?? resolveCurrencyScale(account.currency);
          final MoneyAmount net = rescaleMoneyAmount(
            deltas[account.id] ?? MoneyAmount(minor: BigInt.zero, scale: scale),
            scale,
          );
          final MoneyAmount openingBalance = _resolveOpeningBalance(
            account: account,
            netDelta: net,
          );
          return account.copyWith(
            openingBalanceMinor: openingBalance.minor,
            balanceMinor: openingBalance.minor + net.minor,
            currencyScale: scale,
          );
        })
        .toList(growable: false);
    await _accountDao.upsertAll(updatedAccounts);
  }

  Future<List<AccountEntity>> _loadImportedAccounts(
    List<AccountEntity> importedAccounts,
  ) async {
    final Set<String> importedIds = importedAccounts
        .map((AccountEntity account) => account.id)
        .toSet();
    final List<AccountEntity> accounts = await _accountDao.getAllAccounts();
    return accounts
        .where((AccountEntity account) => importedIds.contains(account.id))
        .toList(growable: false);
  }

  Future<void> _enqueueAccounts(List<AccountEntity> accounts) async {
    for (final AccountEntity account in accounts) {
      await _outboxDao.enqueue(
        entityType: _accountEntityType,
        entityId: account.id,
        operation: OutboxOperation.upsert,
        payload: _mapAccountPayload(account),
      );
    }
  }

  Future<void> _enqueueCategories(List<Category> categories) async {
    for (final Category category in categories) {
      await _outboxDao.enqueue(
        entityType: _categoryEntityType,
        entityId: category.id,
        operation: OutboxOperation.upsert,
        payload: _mapCategoryPayload(category),
      );
    }
  }

  Future<void> _enqueueTags(List<TagEntity> tags) async {
    for (final TagEntity tag in tags) {
      await _outboxDao.enqueue(
        entityType: _tagEntityType,
        entityId: tag.id,
        operation: OutboxOperation.upsert,
        payload: _mapTagPayload(tag),
      );
    }
  }

  Future<void> _enqueueSavingGoals(List<SavingGoal> savingGoals) async {
    for (final SavingGoal goal in savingGoals) {
      await _outboxDao.enqueue(
        entityType: _savingGoalEntityType,
        entityId: goal.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(goal),
      );
    }
  }

  Future<void> _enqueueCredits(List<CreditEntity> credits) async {
    for (final CreditEntity credit in credits) {
      await _outboxDao.enqueue(
        entityType: _creditEntityType,
        entityId: credit.id,
        operation: OutboxOperation.upsert,
        payload: _mapCreditPayload(credit),
      );
    }
  }

  Future<void> _enqueueCreditCards(List<CreditCardEntity> creditCards) async {
    for (final CreditCardEntity creditCard in creditCards) {
      await _outboxDao.enqueue(
        entityType: _creditCardEntityType,
        entityId: creditCard.id,
        operation: OutboxOperation.upsert,
        payload: _mapCreditCardPayload(creditCard),
      );
    }
  }

  Future<void> _enqueueDebts(List<DebtEntity> debts) async {
    for (final DebtEntity debt in debts) {
      await _outboxDao.enqueue(
        entityType: _debtEntityType,
        entityId: debt.id,
        operation: OutboxOperation.upsert,
        payload: _mapDebtPayload(debt),
      );
    }
  }

  Future<void> _enqueueBudgets(List<Budget> budgets) async {
    for (final Budget budget in budgets) {
      await _outboxDao.enqueue(
        entityType: _budgetEntityType,
        entityId: budget.id,
        operation: OutboxOperation.upsert,
        payload: _mapBudgetPayload(budget),
      );
    }
  }

  Future<void> _enqueueBudgetInstances(List<BudgetInstance> instances) async {
    for (final BudgetInstance instance in instances) {
      await _outboxDao.enqueue(
        entityType: _budgetInstanceEntityType,
        entityId: instance.id,
        operation: OutboxOperation.upsert,
        payload: _mapBudgetInstancePayload(instance),
      );
    }
  }

  Future<void> _enqueueTransactions(
    List<TransactionEntity> transactions,
  ) async {
    for (final TransactionEntity transaction in transactions) {
      await _outboxDao.enqueue(
        entityType: _transactionEntityType,
        entityId: transaction.id,
        operation: OutboxOperation.upsert,
        payload: _mapTransactionPayload(transaction),
      );
    }
  }

  Future<void> _enqueueUpcomingPayments(List<UpcomingPayment> payments) async {
    for (final UpcomingPayment payment in payments) {
      await _outboxDao.enqueue(
        entityType: _upcomingPaymentEntityType,
        entityId: payment.id,
        operation: OutboxOperation.upsert,
        payload: payment.toJson(),
      );
    }
  }

  Future<void> _enqueuePaymentReminders(List<PaymentReminder> reminders) async {
    for (final PaymentReminder reminder in reminders) {
      await _outboxDao.enqueue(
        entityType: _paymentReminderEntityType,
        entityId: reminder.id,
        operation: OutboxOperation.upsert,
        payload: reminder.toJson(),
      );
    }
  }

  Future<void> _enqueueTransactionTags(List<TransactionTagEntity> links) async {
    for (final TransactionTagEntity link in links) {
      await _outboxDao.enqueue(
        entityType: _transactionTagEntityType,
        entityId: _transactionTagKey(link),
        operation: OutboxOperation.upsert,
        payload: _mapTransactionTagPayload(link),
      );
    }
  }

  Future<void> _enqueueDeletedSnapshot({
    required _ExistingImportSnapshot existingSnapshot,
    required Iterable<String> importedAccountIds,
    required Iterable<String> importedCategoryIds,
    required Iterable<String> importedTagKeys,
    required Iterable<String> importedTransactionTagKeys,
    required Iterable<String> importedSavingGoalIds,
    required Iterable<String> importedCreditIds,
    required Iterable<String> importedCreditCardIds,
    required Iterable<String> importedDebtIds,
    required Iterable<String> importedBudgetIds,
    required Iterable<String> importedBudgetInstanceIds,
    required Iterable<String> importedUpcomingPaymentIds,
    required Iterable<String> importedPaymentReminderIds,
    required Iterable<String> importedTransactionIds,
    required DateTime syncTimestamp,
  }) async {
    final Set<String> accountIds = importedAccountIds.toSet();
    final Set<String> categoryIds = importedCategoryIds.toSet();
    final Set<String> tagKeys = importedTagKeys.toSet();
    final Set<String> transactionTagKeys = importedTransactionTagKeys.toSet();
    final Set<String> savingGoalIds = importedSavingGoalIds.toSet();
    final Set<String> creditIds = importedCreditIds.toSet();
    final Set<String> creditCardIds = importedCreditCardIds.toSet();
    final Set<String> debtIds = importedDebtIds.toSet();
    final Set<String> budgetIds = importedBudgetIds.toSet();
    final Set<String> budgetInstanceIds = importedBudgetInstanceIds.toSet();
    final Set<String> upcomingPaymentIds = importedUpcomingPaymentIds.toSet();
    final Set<String> paymentReminderIds = importedPaymentReminderIds.toSet();
    final Set<String> transactionIds = importedTransactionIds.toSet();

    for (final AccountEntity account in existingSnapshot.accounts) {
      if (accountIds.contains(account.id)) continue;
      final AccountEntity deleted = account.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _accountEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapAccountPayload(deleted),
      );
    }

    for (final Category category in existingSnapshot.categories) {
      if (categoryIds.contains(category.id)) continue;
      final Category deleted = category.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _categoryEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapCategoryPayload(deleted),
      );
    }

    for (final TagEntity tag in existingSnapshot.tags) {
      if (tagKeys.contains(tag.id)) continue;
      final TagEntity deleted = tag.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _tagEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapTagPayload(deleted),
      );
    }

    for (final SavingGoal goal in existingSnapshot.savingGoals) {
      if (savingGoalIds.contains(goal.id)) continue;
      await _outboxDao.enqueue(
        entityType: _savingGoalEntityType,
        entityId: goal.id,
        operation: OutboxOperation.delete,
        payload: _mapGoalPayload(goal.copyWith(updatedAt: syncTimestamp)),
      );
    }

    for (final CreditEntity credit in existingSnapshot.credits) {
      if (creditIds.contains(credit.id)) continue;
      final CreditEntity deleted = credit.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _creditEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapCreditPayload(deleted),
      );
    }

    for (final CreditCardEntity creditCard in existingSnapshot.creditCards) {
      if (creditCardIds.contains(creditCard.id)) continue;
      final CreditCardEntity deleted = creditCard.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _creditCardEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapCreditCardPayload(deleted),
      );
    }

    for (final DebtEntity debt in existingSnapshot.debts) {
      if (debtIds.contains(debt.id)) continue;
      final DebtEntity deleted = debt.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _debtEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapDebtPayload(deleted),
      );
    }

    for (final Budget budget in existingSnapshot.budgets) {
      if (budgetIds.contains(budget.id)) continue;
      final Budget deleted = budget.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _budgetEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapBudgetPayload(deleted),
      );
    }

    for (final BudgetInstance instance in existingSnapshot.budgetInstances) {
      if (budgetInstanceIds.contains(instance.id)) continue;
      final BudgetInstance deleted = instance.copyWith(
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _budgetInstanceEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapBudgetInstancePayload(deleted, deleted: true),
      );
    }

    for (final TransactionEntity transaction in existingSnapshot.transactions) {
      if (transactionIds.contains(transaction.id)) continue;
      final TransactionEntity deleted = transaction.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _transactionEntityType,
        entityId: deleted.id,
        operation: OutboxOperation.delete,
        payload: _mapTransactionPayload(deleted),
      );
    }

    for (final TransactionTagEntity link in existingSnapshot.transactionTags) {
      final String key = _transactionTagKey(link);
      if (transactionTagKeys.contains(key)) continue;
      final TransactionTagEntity deleted = link.copyWith(
        isDeleted: true,
        updatedAt: syncTimestamp,
      );
      await _outboxDao.enqueue(
        entityType: _transactionTagEntityType,
        entityId: key,
        operation: OutboxOperation.delete,
        payload: _mapTransactionTagPayload(deleted),
      );
    }

    for (final UpcomingPayment payment in existingSnapshot.upcomingPayments) {
      if (upcomingPaymentIds.contains(payment.id)) continue;
      await _outboxDao.enqueue(
        entityType: _upcomingPaymentEntityType,
        entityId: payment.id,
        operation: OutboxOperation.delete,
        payload: payment
            .copyWith(
              isActive: false,
              updatedAtMs: syncTimestamp.millisecondsSinceEpoch,
            )
            .toJson(),
      );
    }

    for (final PaymentReminder reminder in existingSnapshot.paymentReminders) {
      if (paymentReminderIds.contains(reminder.id)) continue;
      await _outboxDao.enqueue(
        entityType: _paymentReminderEntityType,
        entityId: reminder.id,
        operation: OutboxOperation.delete,
        payload: reminder
            .copyWith(
              isDone: true,
              updatedAtMs: syncTimestamp.millisecondsSinceEpoch,
            )
            .toJson(),
      );
    }
  }

  MoneyAmount _resolveOpeningBalance({
    required AccountEntity account,
    required MoneyAmount netDelta,
  }) {
    final MoneyAmount balance = rescaleMoneyAmount(
      account.balanceAmount,
      netDelta.scale,
    );
    final MoneyAmount opening = rescaleMoneyAmount(
      account.openingBalanceAmount,
      netDelta.scale,
    );
    final BigInt derivedMinor = balance.minor - netDelta.minor;
    if (opening.minor == BigInt.zero && netDelta.minor != BigInt.zero) {
      return MoneyAmount(minor: derivedMinor, scale: netDelta.scale);
    }
    if (opening.minor == balance.minor && netDelta.minor != BigInt.zero) {
      return MoneyAmount(minor: derivedMinor, scale: netDelta.scale);
    }
    return opening;
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

  Map<String, dynamic> _mapCategoryPayload(Category category) {
    final Map<String, dynamic> json = category.toJson();
    json['iconName'] = category.icon?.name;
    json['iconStyle'] = category.icon?.style.label;
    json['parentId'] = category.parentId;
    json['createdAt'] = category.createdAt.toIso8601String();
    json['updatedAt'] = category.updatedAt.toIso8601String();
    json['isSystem'] = category.isSystem;
    json['isHidden'] = category.isHidden;
    json['isFavorite'] = category.isFavorite;
    return json;
  }

  Map<String, dynamic> _mapTagPayload(TagEntity tag) {
    final Map<String, dynamic> json = tag.toJson();
    json['createdAt'] = tag.createdAt.toIso8601String();
    json['updatedAt'] = tag.updatedAt.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapGoalPayload(SavingGoal goal) {
    final Map<String, dynamic> json = goal.toJson();
    json['createdAt'] = goal.createdAt.toIso8601String();
    json['updatedAt'] = goal.updatedAt.toIso8601String();
    json['archivedAt'] = goal.archivedAt?.toIso8601String();
    json['targetDate'] = goal.targetDate?.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapTransactionPayload(TransactionEntity transaction) {
    final Map<String, dynamic> json = transaction.toJson();
    json['createdAt'] = transaction.createdAt.toIso8601String();
    json['updatedAt'] = transaction.updatedAt.toIso8601String();
    json['date'] = transaction.date.toIso8601String();
    json['savingGoalId'] = transaction.savingGoalId;
    json['idempotencyKey'] = transaction.idempotencyKey;
    json['groupId'] = transaction.groupId;
    json['amountMinor'] = transaction.amountMinor?.toString();
    json['amountScale'] = transaction.amountScale;
    return json;
  }

  Map<String, dynamic> _mapCreditPayload(CreditEntity credit) {
    final Map<String, dynamic> json = credit.toJson();
    json['startDate'] = credit.startDate.toIso8601String();
    json['firstPaymentDate'] = credit.firstPaymentDate?.toIso8601String();
    json['createdAt'] = credit.createdAt.toIso8601String();
    json['updatedAt'] = credit.updatedAt.toIso8601String();
    json['totalAmountMinor'] = credit.totalAmountMinor?.toString();
    json['totalAmountScale'] = credit.totalAmountScale;
    return json;
  }

  Map<String, dynamic> _mapCreditCardPayload(CreditCardEntity creditCard) {
    final Map<String, dynamic> json = creditCard.toJson();
    json['createdAt'] = creditCard.createdAt.toIso8601String();
    json['updatedAt'] = creditCard.updatedAt.toIso8601String();
    json['creditLimitMinor'] = creditCard.creditLimitMinor?.toString();
    json['creditLimitScale'] = creditCard.creditLimitScale;
    return json;
  }

  Map<String, dynamic> _mapDebtPayload(DebtEntity debt) {
    final Map<String, dynamic> json = debt.toJson();
    json['dueDate'] = debt.dueDate.toIso8601String();
    json['createdAt'] = debt.createdAt.toIso8601String();
    json['updatedAt'] = debt.updatedAt.toIso8601String();
    json['amountMinor'] = debt.amountMinor?.toString();
    json['amountScale'] = debt.amountScale;
    return json;
  }

  Map<String, dynamic> _mapTransactionTagPayload(TransactionTagEntity link) {
    final Map<String, dynamic> json = link.toJson();
    json['createdAt'] = link.createdAt.toIso8601String();
    json['updatedAt'] = link.updatedAt.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapBudgetPayload(Budget budget) {
    final Map<String, dynamic> json = budget.toJson();
    final MoneyAmount amount = budget.amountValue;
    json['startDate'] = budget.startDate.toIso8601String();
    json['endDate'] = budget.endDate?.toIso8601String();
    json['createdAt'] = budget.createdAt.toIso8601String();
    json['updatedAt'] = budget.updatedAt.toIso8601String();
    json['amount'] = amount.toDouble();
    json['amountMinor'] = amount.minor.toString();
    json['amountScale'] = amount.scale;
    return json;
  }

  Map<String, dynamic> _mapBudgetInstancePayload(
    BudgetInstance instance, {
    bool deleted = false,
  }) {
    final MoneyAmount amount = instance.amountValue;
    final MoneyAmount spent = instance.spentValue;
    return <String, dynamic>{
      'id': instance.id,
      'budgetId': instance.budgetId,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'amount': amount.toDouble(),
      'amountMinor': amount.minor.toString(),
      'spent': spent.toDouble(),
      'spentMinor': spent.minor.toString(),
      'amountScale': amount.scale,
      'status': instance.status.storageValue,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deleted': deleted,
    };
  }

  Future<void> _upsertUpcomingPayments(List<UpcomingPayment> payments) async {
    for (final UpcomingPayment payment in payments) {
      await _upcomingPaymentsDao.upsert(payment);
    }
  }

  Future<void> _upsertPaymentReminders(List<PaymentReminder> reminders) async {
    for (final PaymentReminder reminder in reminders) {
      await _paymentRemindersDao.upsert(reminder);
    }
  }

  String _transactionTagKey(TransactionTagEntity link) {
    return '${link.transactionId}::${link.tagId}';
  }
}

class _ExistingImportSnapshot {
  const _ExistingImportSnapshot({
    required this.accounts,
    required this.categories,
    required this.tags,
    required this.transactionTags,
    required this.savingGoals,
    required this.credits,
    required this.creditCards,
    required this.debts,
    required this.budgets,
    required this.budgetInstances,
    required this.upcomingPayments,
    required this.paymentReminders,
    required this.transactions,
  });

  final List<AccountEntity> accounts;
  final List<Category> categories;
  final List<TagEntity> tags;
  final List<TransactionTagEntity> transactionTags;
  final List<SavingGoal> savingGoals;
  final List<CreditEntity> credits;
  final List<CreditCardEntity> creditCards;
  final List<DebtEntity> debts;
  final List<Budget> budgets;
  final List<BudgetInstance> budgetInstances;
  final List<UpcomingPayment> upcomingPayments;
  final List<PaymentReminder> paymentReminders;
  final List<TransactionEntity> transactions;
}
