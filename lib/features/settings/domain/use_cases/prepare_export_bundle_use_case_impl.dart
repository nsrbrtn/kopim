import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/repositories/export_data_repository.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_integrity_service.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_schema.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_validator.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Реализация сборки экспортного бандла на основе локального репозитория.
class PrepareExportBundleUseCaseImpl implements PrepareExportBundleUseCase {
  PrepareExportBundleUseCaseImpl({
    required ExportDataRepository repository,
    DateTime Function()? clock,
    String? schemaVersion,
    ExportBundleValidator? validator,
    ExportBundleIntegrityService? integrityService,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now,
       _schemaVersion = schemaVersion ?? _defaultSchemaVersion,
       _validator = validator ?? const ExportBundleValidator(),
       _integrityService =
           integrityService ?? const ExportBundleIntegrityService();

  final ExportDataRepository _repository;
  final DateTime Function() _clock;
  final String _schemaVersion;
  final ExportBundleValidator _validator;
  final ExportBundleIntegrityService _integrityService;

  static const String _defaultSchemaVersion = ExportBundleSchema.currentVersion;

  @override
  Future<ExportBundle> call() async {
    final DateTime generatedAt = _clock().toUtc();

    final Future<List<AccountEntity>> accountsFuture = _repository
        .fetchAccounts();
    final Future<List<TransactionEntity>> transactionsFuture = _repository
        .fetchTransactions();
    final Future<List<Category>> categoriesFuture = _repository
        .fetchCategories();
    final Future<List<TagEntity>> tagsFuture = _repository.fetchTags();
    final Future<List<TransactionTagEntity>> transactionTagsFuture = _repository
        .fetchTransactionTags();
    final Future<List<SavingGoal>> savingGoalsFuture = _repository
        .fetchSavingGoals();
    final Future<List<CreditEntity>> creditsFuture = _repository.fetchCredits();
    final Future<List<CreditCardEntity>> creditCardsFuture = _repository
        .fetchCreditCards();
    final Future<List<DebtEntity>> debtsFuture = _repository.fetchDebts();
    final Future<List<Budget>> budgetsFuture = _repository.fetchBudgets();
    final Future<List<BudgetInstance>> budgetInstancesFuture = _repository
        .fetchBudgetInstances();
    final Future<List<UpcomingPayment>> upcomingPaymentsFuture = _repository
        .fetchUpcomingPayments();
    final Future<List<PaymentReminder>> paymentRemindersFuture = _repository
        .fetchPaymentReminders();
    final Future<Profile?> profileFuture = _repository.fetchProfile();
    final Future<UserProgress> progressFuture = _repository.fetchProgress();

    final List<AccountEntity> accounts = await accountsFuture;
    final List<TransactionEntity> transactions = await transactionsFuture;
    final List<Category> categories = await categoriesFuture;
    final List<TagEntity> tags = await tagsFuture;
    final List<TransactionTagEntity> transactionTags =
        await transactionTagsFuture;
    final List<SavingGoal> savingGoals = await savingGoalsFuture;
    final List<CreditEntity> credits = await creditsFuture;
    final List<CreditCardEntity> creditCards = await creditCardsFuture;
    final List<DebtEntity> debts = await debtsFuture;
    final List<Budget> budgets = await budgetsFuture;
    final List<BudgetInstance> budgetInstances = await budgetInstancesFuture;
    final List<UpcomingPayment> upcomingPayments = await upcomingPaymentsFuture;
    final List<PaymentReminder> paymentReminders = await paymentRemindersFuture;
    final Profile? profile = await profileFuture;
    final UserProgress progress = await progressFuture;

    final ExportBundle bundle = ExportBundle(
      schemaVersion: _schemaVersion,
      generatedAt: generatedAt,
      accounts: accounts,
      transactions: transactions,
      categories: categories,
      tags: tags,
      transactionTags: transactionTags,
      savingGoals: savingGoals,
      credits: credits,
      creditCards: creditCards,
      debts: debts,
      budgets: budgets,
      budgetInstances: budgetInstances,
      upcomingPayments: upcomingPayments,
      paymentReminders: paymentReminders,
      profile: profile,
      progress: progress.copyWith(updatedAt: generatedAt),
    );
    _validator.validateOrThrow(bundle);
    return bundle.copyWith(integrity: _integrityService.buildIntegrity(bundle));
  }
}
