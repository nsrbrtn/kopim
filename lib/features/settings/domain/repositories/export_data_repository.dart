import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Контракт на получение полного снимка локальных данных для экспорта.
abstract class ExportDataRepository {
  /// Возвращает все счета, включая скрытые/удалённые, если они присутствуют.
  Future<List<AccountEntity>> fetchAccounts();

  /// Возвращает все транзакции без фильтрации по состоянию.
  Future<List<TransactionEntity>> fetchTransactions();

  /// Возвращает все категории с метаданными.
  Future<List<Category>> fetchCategories();

  /// Возвращает все теги.
  Future<List<TagEntity>> fetchTags();

  /// Возвращает все связи транзакций и тегов.
  Future<List<TransactionTagEntity>> fetchTransactionTags();

  /// Возвращает все цели накоплений.
  Future<List<SavingGoal>> fetchSavingGoals();

  /// Возвращает все кредиты.
  Future<List<CreditEntity>> fetchCredits();

  /// Возвращает все кредитные карты.
  Future<List<CreditCardEntity>> fetchCreditCards();

  /// Возвращает все долги.
  Future<List<DebtEntity>> fetchDebts();

  /// Возвращает все бюджеты.
  Future<List<Budget>> fetchBudgets();

  /// Возвращает все инстансы бюджетов.
  Future<List<BudgetInstance>> fetchBudgetInstances();

  /// Возвращает все recurring payments.
  Future<List<UpcomingPayment>> fetchUpcomingPayments();

  /// Возвращает все reminders.
  Future<List<PaymentReminder>> fetchPaymentReminders();
}
