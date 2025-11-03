import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Репозиторий, сохраняющий импортированные данные через Drift DAO.
class ImportDataRepositoryImpl implements ImportDataRepository {
  ImportDataRepositoryImpl({
    required AccountDao accountDao,
    required CategoryDao categoryDao,
    required TransactionDao transactionDao,
  }) : _accountDao = accountDao,
       _categoryDao = categoryDao,
       _transactionDao = transactionDao;

  final AccountDao _accountDao;
  final CategoryDao _categoryDao;
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
  Future<void> upsertTransactions(List<TransactionEntity> transactions) {
    return _transactionDao.upsertAll(transactions);
  }
}
