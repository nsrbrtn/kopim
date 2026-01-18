import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/transactions/data/services/transaction_balance_helper.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Репозиторий, сохраняющий импортированные данные через Drift DAO.
class ImportDataRepositoryImpl implements ImportDataRepository {
  ImportDataRepositoryImpl({
    required AccountDao accountDao,
    required CategoryDao categoryDao,
    required CreditDao creditDao,
    required TransactionDao transactionDao,
  }) : _accountDao = accountDao,
       _categoryDao = categoryDao,
       _creditDao = creditDao,
       _transactionDao = transactionDao;

  final AccountDao _accountDao;
  final CategoryDao _categoryDao;
  final CreditDao _creditDao;
  final TransactionDao _transactionDao;

  @override
  Future<void> upsertAccounts(List<AccountEntity> accounts) {
    return _accountDao.upsertAll(accounts);
  }

  @override
  Future<void> upsertCategories(List<Category> categories) {
    return _categoryDao.upsertAll(categories);
  }

  @override
  Future<void> upsertTransactions(List<TransactionEntity> transactions) async {
    await _transactionDao.upsertAll(transactions);
    await _recalculateAccountBalances(transactions);
  }

  Future<void> _recalculateAccountBalances(
    List<TransactionEntity> transactions,
  ) async {
    final List<AccountEntity> accounts = await _accountDao.getAllAccounts();
    final Map<String, double> deltas = <String, double>{
      for (final AccountEntity account in accounts) account.id: 0,
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
      final Map<String, double> effect = buildTransactionEffect(
        transaction: transaction,
        creditAccountId: creditAccountId,
      );
      applyTransactionEffect(deltas, effect);
    }

    final List<AccountEntity> updatedAccounts = accounts
        .map(
          (AccountEntity account) {
            final double net = deltas[account.id] ?? 0;
            final double openingBalance = _resolveOpeningBalance(
              account: account,
              netDelta: net,
            );
            return account.copyWith(
              openingBalance: openingBalance,
              balance: openingBalance + net,
            );
          },
        )
        .toList(growable: false);
    await _accountDao.upsertAll(updatedAccounts);
  }

  double _resolveOpeningBalance({
    required AccountEntity account,
    required double netDelta,
  }) {
    const double epsilon = 1e-9;
    final double derived = account.balance - netDelta;
    if (account.openingBalance == 0 && netDelta.abs() > epsilon) {
      return derived;
    }
    if ((account.openingBalance - account.balance).abs() < epsilon &&
        netDelta.abs() > epsilon) {
      return derived;
    }
    return account.openingBalance;
  }
}
