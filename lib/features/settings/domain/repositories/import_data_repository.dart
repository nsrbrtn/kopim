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

/// Репозиторий, отвечающий за сохранение импортируемых данных.
abstract class ImportDataRepository {
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
  });
}
