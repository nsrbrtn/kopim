import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
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
    final Map<String, MoneyAmount> deltas = <String, MoneyAmount>{
      for (final AccountEntity account in accounts)
        account.id: MoneyAmount(
          minor: BigInt.zero,
          scale: account.currencyScale ?? resolveCurrencyScale(account.currency),
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
        .map(
          (AccountEntity account) {
            final int scale =
                account.currencyScale ?? resolveCurrencyScale(account.currency);
            final MoneyAmount net =
                rescaleMoneyAmount(deltas[account.id] ?? MoneyAmount(
                  minor: BigInt.zero,
                  scale: scale,
                ), scale);
            final MoneyAmount openingBalance = _resolveOpeningBalance(
              account: account,
              netDelta: net,
            );
            return account.copyWith(
              openingBalanceMinor: openingBalance.minor,
              balanceMinor: openingBalance.minor + net.minor,
              currencyScale: scale,
            );
          },
        )
        .toList(growable: false);
    await _accountDao.upsertAll(updatedAccounts);
  }

  MoneyAmount _resolveOpeningBalance({
    required AccountEntity account,
    required MoneyAmount netDelta,
  }) {
    final MoneyAmount balance =
        rescaleMoneyAmount(account.balanceAmount, netDelta.scale);
    final MoneyAmount opening =
        rescaleMoneyAmount(account.openingBalanceAmount, netDelta.scale);
    final BigInt derivedMinor = balance.minor - netDelta.minor;
    if (opening.minor == BigInt.zero && netDelta.minor != BigInt.zero) {
      return MoneyAmount(minor: derivedMinor, scale: netDelta.scale);
    }
    if (opening.minor == balance.minor && netDelta.minor != BigInt.zero) {
      return MoneyAmount(minor: derivedMinor, scale: netDelta.scale);
    }
    return opening;
  }
}
