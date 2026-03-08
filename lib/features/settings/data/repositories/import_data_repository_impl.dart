import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/transactions/data/services/transaction_balance_helper.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Репозиторий, сохраняющий импортированные данные через Drift DAO.
class ImportDataRepositoryImpl implements ImportDataRepository {
  ImportDataRepositoryImpl({
    required db.AppDatabase database,
    required AccountDao accountDao,
    required CategoryDao categoryDao,
    required CreditDao creditDao,
    required SavingGoalDao savingGoalDao,
    required TransactionDao transactionDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _accountDao = accountDao,
       _categoryDao = categoryDao,
       _creditDao = creditDao,
       _savingGoalDao = savingGoalDao,
       _transactionDao = transactionDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final AccountDao _accountDao;
  final CategoryDao _categoryDao;
  final CreditDao _creditDao;
  final SavingGoalDao _savingGoalDao;
  final TransactionDao _transactionDao;
  final OutboxDao _outboxDao;

  static const String _accountEntityType = 'account';
  static const String _categoryEntityType = 'category';
  static const String _savingGoalEntityType = 'saving_goal';
  static const String _transactionEntityType = 'transaction';

  @override
  Future<void> importData({
    required List<AccountEntity> accounts,
    required List<Category> categories,
    required List<SavingGoal> savingGoals,
    required List<TransactionEntity> transactions,
  }) async {
    await _database.transaction(() async {
      await _accountDao.upsertAll(accounts);
      await _categoryDao.upsertAll(categories);
      await _savingGoalDao.upsertAll(savingGoals);
      await _transactionDao.upsertAll(transactions);
      await _recalculateAccountBalances(transactions);

      final List<AccountEntity> persistedAccounts = await _loadImportedAccounts(
        accounts,
      );
      await _enqueueAccounts(persistedAccounts);
      await _enqueueCategories(categories);
      await _enqueueSavingGoals(savingGoals);
      await _enqueueTransactions(transactions);
    });
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
}
