import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/repositories/export_data_repository.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Репозиторий экспорта, собирающий данные напрямую из DAO Drift.
class ExportDataRepositoryImpl implements ExportDataRepository {
  ExportDataRepositoryImpl({
    required AccountDao accountDao,
    required TransactionDao transactionDao,
    required CategoryDao categoryDao,
    required SavingGoalDao savingGoalDao,
  }) : _accountDao = accountDao,
       _transactionDao = transactionDao,
       _categoryDao = categoryDao,
       _savingGoalDao = savingGoalDao;

  final AccountDao _accountDao;
  final TransactionDao _transactionDao;
  final CategoryDao _categoryDao;
  final SavingGoalDao _savingGoalDao;

  @override
  Future<List<AccountEntity>> fetchAccounts() {
    return _accountDao.getAllAccounts();
  }

  @override
  Future<List<TransactionEntity>> fetchTransactions() {
    return _transactionDao.getAllTransactions();
  }

  @override
  Future<List<Category>> fetchCategories() {
    return _categoryDao.getAllCategories();
  }

  @override
  Future<List<SavingGoal>> fetchSavingGoals() {
    return _savingGoalDao.getGoals(includeArchived: true);
  }
}
