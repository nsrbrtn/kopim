import 'package:freezed_annotation/freezed_annotation.dart';
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

part 'export_bundle.freezed.dart';
part 'export_bundle.g.dart';

/// Снимок пользовательских данных, подготовленный для экспорта.
@freezed
abstract class ExportBundle with _$ExportBundle {
  const ExportBundle._();

  const factory ExportBundle({
    /// Версия схемы экспортируемых данных.
    required String schemaVersion,

    /// Временная метка формирования бандла.
    required DateTime generatedAt,

    /// Набор локальных счетов.
    @Default(<AccountEntity>[]) List<AccountEntity> accounts,

    /// Набор локальных транзакций.
    @Default(<TransactionEntity>[]) List<TransactionEntity> transactions,

    /// Набор локальных категорий.
    @Default(<Category>[]) List<Category> categories,

    /// Набор локальных тегов.
    @Default(<TagEntity>[]) List<TagEntity> tags,

    /// Набор связей транзакций и тегов.
    @Default(<TransactionTagEntity>[])
    List<TransactionTagEntity> transactionTags,

    /// Набор локальных целей накоплений.
    @Default(<SavingGoal>[]) List<SavingGoal> savingGoals,

    /// Набор локальных кредитов.
    @Default(<CreditEntity>[]) List<CreditEntity> credits,

    /// Набор локальных кредитных карт.
    @Default(<CreditCardEntity>[]) List<CreditCardEntity> creditCards,

    /// Набор локальных долгов.
    @Default(<DebtEntity>[]) List<DebtEntity> debts,

    /// Набор локальных бюджетов.
    @Default(<Budget>[]) List<Budget> budgets,

    /// Набор локальных инстансов бюджетов.
    @Default(<BudgetInstance>[]) List<BudgetInstance> budgetInstances,

    /// Набор локальных recurring payments.
    @Default(<UpcomingPayment>[]) List<UpcomingPayment> upcomingPayments,

    /// Набор локальных reminders.
    @Default(<PaymentReminder>[]) List<PaymentReminder> paymentReminders,
  }) = _ExportBundle;

  factory ExportBundle.fromJson(Map<String, Object?> json) =>
      _$ExportBundleFromJson(json);
}
