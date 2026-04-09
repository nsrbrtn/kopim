import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
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
import 'package:kopim/features/settings/domain/repositories/export_data_repository.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Репозиторий экспорта, собирающий данные напрямую из DAO Drift.
class ExportDataRepositoryImpl implements ExportDataRepository {
  ExportDataRepositoryImpl({
    required AccountDao accountDao,
    required TransactionDao transactionDao,
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
  }) : _accountDao = accountDao,
       _transactionDao = transactionDao,
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
       _paymentRemindersDao = paymentRemindersDao;

  final AccountDao _accountDao;
  final TransactionDao _transactionDao;
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
  Future<List<TagEntity>> fetchTags() {
    return _tagDao.getAllTags();
  }

  @override
  Future<List<TransactionTagEntity>> fetchTransactionTags() async {
    return (await _transactionTagsDao.getAllTransactionTags())
        .map(_transactionTagsDao.mapRowToEntity)
        .toList(growable: false);
  }

  @override
  Future<List<SavingGoal>> fetchSavingGoals() {
    return _savingGoalDao.getGoals(includeArchived: true);
  }

  @override
  Future<List<CreditEntity>> fetchCredits() async {
    return (await _creditDao.getAllCredits())
        .map(_creditDao.mapRowToEntity)
        .toList(growable: false);
  }

  @override
  Future<List<CreditCardEntity>> fetchCreditCards() async {
    return (await _creditCardDao.getAllCreditCards())
        .map(_creditCardDao.mapRowToEntity)
        .toList(growable: false);
  }

  @override
  Future<List<DebtEntity>> fetchDebts() async {
    return (await _debtDao.getAllDebts())
        .map(_debtDao.mapRowToEntity)
        .toList(growable: false);
  }

  @override
  Future<List<Budget>> fetchBudgets() {
    return _budgetDao.getAllBudgets();
  }

  @override
  Future<List<BudgetInstance>> fetchBudgetInstances() {
    return _budgetInstanceDao.getAllInstances();
  }

  @override
  Future<List<UpcomingPayment>> fetchUpcomingPayments() {
    return _upcomingPaymentsDao.getAll();
  }

  @override
  Future<List<PaymentReminder>> fetchPaymentReminders() async {
    return _paymentRemindersDao.getAllIncludingDone();
  }
}
