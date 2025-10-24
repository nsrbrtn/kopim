import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod/riverpod.dart' as rp;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/core/services/exact_alarm_permission_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notifications_service.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/ai/data/repositories/ai_assistant_repository_impl.dart';
import 'package:kopim/features/ai/data/repositories/ai_financial_data_repository_impl.dart';
import 'package:kopim/features/ai/domain/repositories/ai_assistant_repository.dart';
import 'package:kopim/features/ai/domain/use_cases/get_ai_financial_overview_use_case.dart';
import 'package:kopim/features/ai/domain/use_cases/ask_financial_assistant_use_case.dart';
import 'package:kopim/features/ai/domain/use_cases/watch_ai_financial_overview_use_case.dart';
import 'package:kopim/features/ai/domain/use_cases/watch_ai_recommendations_use_case.dart';
import 'package:kopim/features/ai/domain/use_cases/watch_ai_analytics_use_case.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/domain/use_cases/delete_account_use_case.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/budgets/domain/use_cases/delete_budget_use_case.dart';
import 'package:kopim/features/budgets/domain/use_cases/save_budget_use_case.dart';
import 'package:kopim/features/budgets/domain/use_cases/watch_budgets_use_case.dart';
import 'package:kopim/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart';
import 'package:kopim/features/home/domain/use_cases/watch_upcoming_payments_use_case.dart';
import 'package:kopim/features/categories/data/repositories/category_repository_impl.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/watch_categories_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/watch_category_tree_use_case.dart';
import 'package:kopim/features/savings/data/repositories/saving_goal_repository_impl.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/savings/domain/use_cases/add_contribution_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/archive_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/create_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/get_saving_goals_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/update_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/watch_saving_goal_analytics_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/watch_saving_goals_use_case.dart';
import 'package:kopim/features/profile/data/auth_repository_impl.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/profile_avatar_repository_impl.dart';
import 'package:kopim/features/profile/data/profile_repository_impl.dart';
import 'package:kopim/features/profile/data/remote/avatar_remote_data_source.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/data/remote/user_progress_remote_data_source.dart';
import 'package:kopim/features/profile/data/user_progress_repository_impl.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_created_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_deleted_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/recompute_user_progress_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_avatar_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case_impl.dart';

import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/delete_transaction_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/update_transaction_use_case.dart';
import 'package:uuid/uuid.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_account_transactions_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_recent_transactions_use_case.dart';
import 'package:kopim/features/home/data/repositories/home_dashboard_preferences_repository_impl.dart';
import 'package:kopim/features/home/domain/repositories/home_dashboard_preferences_repository.dart';
import 'package:kopim/features/home/domain/use_cases/group_transactions_by_day_use_case.dart';
import 'package:kopim/features/recurring_transactions/data/repositories/recurring_transactions_repository_impl.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_window_service.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_work_scheduler.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/job_queue_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_occurrence_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_execution_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/remote/recurring_rule_remote_data_source.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_engine.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/delete_recurring_rule_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/regenerate_rule_window_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/save_recurring_rule_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/toggle_recurring_rule_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/watch_recurring_rules_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/watch_upcoming_occurrences_use_case.dart';
import 'package:kopim/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/repositories/payment_reminders_repository_impl.dart';
import 'package:kopim/features/upcoming_payments/data/drift/repositories/upcoming_payments_repository_impl.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';

part 'injectors.g.dart';

const List<String> _kDefaultAiModelFallbacks = <String>[];

@riverpod
LoggerService loggerService(Ref ref) => LoggerService();

@riverpod
AnalyticsService analyticsService(Ref ref) => const AnalyticsService();

@riverpod
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
FirebaseStorage firebaseStorage(Ref ref) => FirebaseStorage.instance;

@riverpod
FirebaseRemoteConfig firebaseRemoteConfig(Ref ref) =>
    FirebaseRemoteConfig.instance;

@riverpod
LevelPolicy levelPolicy(Ref ref) => const SimpleLevelPolicy();

@riverpod
Connectivity connectivity(Ref ref) => Connectivity();

@riverpod
Uuid uuidGenerator(Ref ref) => const Uuid();

@Riverpod(keepAlive: true)
AiAssistantService aiAssistantService(Ref ref) {
  return AiAssistantService(
    configLoader: () => ref.read(generativeAiConfigProvider.future),
    analyticsService: ref.watch(analyticsServiceProvider),
    loggerService: ref.watch(loggerServiceProvider),
    fallbackModels: _kDefaultAiModelFallbacks,
  );
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}

@riverpod
OutboxDao outboxDao(Ref ref) => OutboxDao(ref.watch(appDatabaseProvider));

@riverpod
AccountDao accountDao(Ref ref) => AccountDao(ref.watch(appDatabaseProvider));

@riverpod
CategoryDao categoryDao(Ref ref) => CategoryDao(ref.watch(appDatabaseProvider));

@riverpod
TransactionDao transactionDao(Ref ref) =>
    TransactionDao(ref.watch(appDatabaseProvider));

@riverpod
BudgetDao budgetDao(Ref ref) => BudgetDao(ref.watch(appDatabaseProvider));

@riverpod
BudgetInstanceDao budgetInstanceDao(Ref ref) =>
    BudgetInstanceDao(ref.watch(appDatabaseProvider));

@riverpod
SavingGoalDao savingGoalDao(Ref ref) =>
    SavingGoalDao(ref.watch(appDatabaseProvider));

@riverpod
GoalContributionDao goalContributionDao(Ref ref) =>
    GoalContributionDao(ref.watch(appDatabaseProvider));

@riverpod
ProfileDao profileDao(Ref ref) => ProfileDao(ref.watch(appDatabaseProvider));

@riverpod
RecurringRuleDao recurringRuleDao(Ref ref) =>
    RecurringRuleDao(ref.watch(appDatabaseProvider));

@riverpod
RecurringOccurrenceDao recurringOccurrenceDao(Ref ref) =>
    RecurringOccurrenceDao(ref.watch(appDatabaseProvider));

@riverpod
RecurringRuleExecutionDao recurringRuleExecutionDao(Ref ref) =>
    RecurringRuleExecutionDao(ref.watch(appDatabaseProvider));

@riverpod
JobQueueDao jobQueueDao(Ref ref) => JobQueueDao(ref.watch(appDatabaseProvider));

@riverpod
UpcomingPaymentsDao upcomingPaymentsDao(Ref ref) =>
    UpcomingPaymentsDao(ref.watch(appDatabaseProvider));

@riverpod
PaymentRemindersDao paymentRemindersDao(Ref ref) =>
    PaymentRemindersDao(ref.watch(appDatabaseProvider));

@riverpod
RecurringRuleRemoteDataSource recurringRuleRemoteDataSource(Ref ref) =>
    RecurringRuleRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin(Ref ref) =>
    FlutterLocalNotificationsPlugin();

@riverpod
NotificationsService notificationsService(Ref ref) {
  final NotificationsService service = NotificationsService(
    plugin: ref.watch(flutterLocalNotificationsPluginProvider),
    logger: ref.watch(loggerServiceProvider),
    exactAlarmPermissionService: ref.watch(exactAlarmPermissionServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
Workmanager workmanager(Ref ref) => Workmanager();

@riverpod
UpcomingPaymentsWorkScheduler upcomingPaymentsWorkScheduler(Ref ref) =>
    UpcomingPaymentsWorkScheduler(
      workmanager: ref.watch(workmanagerProvider),
      logger: ref.watch(loggerServiceProvider),
    );

@riverpod
RecurringRuleEngine recurringRuleEngine(Ref ref) => RecurringRuleEngine();

@riverpod
BudgetSchedule budgetSchedule(Ref ref) => const BudgetSchedule();

@riverpod
AccountRemoteDataSource accountRemoteDataSource(Ref ref) =>
    AccountRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
CategoryRemoteDataSource categoryRemoteDataSource(Ref ref) =>
    CategoryRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
TransactionRemoteDataSource transactionRemoteDataSource(Ref ref) =>
    TransactionRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) =>
    ProfileRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
AvatarRemoteDataSource avatarRemoteDataSource(Ref ref) =>
    AvatarRemoteDataSource(ref.watch(firebaseStorageProvider));

@riverpod
UserProgressRemoteDataSource userProgressRemoteDataSource(Ref ref) =>
    UserProgressRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
BudgetRemoteDataSource budgetRemoteDataSource(Ref ref) =>
    BudgetRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
BudgetInstanceRemoteDataSource budgetInstanceRemoteDataSource(Ref ref) =>
    BudgetInstanceRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
SavingGoalRemoteDataSource savingGoalRemoteDataSource(Ref ref) =>
    SavingGoalRemoteDataSource(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
AiAssistantRepository aiAssistantRepository(Ref ref) {
  return AiAssistantRepositoryImpl(
    service: ref.watch(aiAssistantServiceProvider),
    financialDataRepository: ref.watch(aiFinancialDataRepositoryProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    loggerService: ref.watch(loggerServiceProvider),
    uuid: ref.watch(uuidGeneratorProvider),
  );
}

@riverpod
AskFinancialAssistantUseCase askFinancialAssistantUseCase(Ref ref) =>
    AskFinancialAssistantUseCase(ref.watch(aiAssistantRepositoryProvider));

@riverpod
WatchAiRecommendationsUseCase watchAiRecommendationsUseCase(Ref ref) =>
    WatchAiRecommendationsUseCase(ref.watch(aiAssistantRepositoryProvider));

@riverpod
WatchAiAnalyticsUseCase watchAiAnalyticsUseCase(Ref ref) =>
    WatchAiAnalyticsUseCase(ref.watch(aiAssistantRepositoryProvider));

@riverpod
AccountRepository accountRepository(Ref ref) => AccountRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  accountDao: ref.watch(accountDaoProvider),
  outboxDao: ref.watch(outboxDaoProvider),
);

@riverpod
AddAccountUseCase addAccountUseCase(Ref ref) =>
    AddAccountUseCase(ref.watch(accountRepositoryProvider));

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) =>
    DeleteAccountUseCase(ref.watch(accountRepositoryProvider));

@riverpod
WatchAccountsUseCase watchAccountsUseCase(Ref ref) =>
    WatchAccountsUseCase(ref.watch(accountRepositoryProvider));

@riverpod
WatchBudgetsUseCase watchBudgetsUseCase(Ref ref) =>
    WatchBudgetsUseCase(repository: ref.watch(budgetRepositoryProvider));

@riverpod
SaveBudgetUseCase saveBudgetUseCase(Ref ref) =>
    SaveBudgetUseCase(repository: ref.watch(budgetRepositoryProvider));

@riverpod
DeleteBudgetUseCase deleteBudgetUseCase(Ref ref) =>
    DeleteBudgetUseCase(repository: ref.watch(budgetRepositoryProvider));

@riverpod
ComputeBudgetProgressUseCase computeBudgetProgressUseCase(Ref ref) =>
    ComputeBudgetProgressUseCase(schedule: ref.watch(budgetScheduleProvider));

@riverpod
CreateSavingGoalUseCase createSavingGoalUseCase(Ref ref) =>
    CreateSavingGoalUseCase(
      repository: ref.watch(savingGoalRepositoryProvider),
      authRepository: ref.watch(authRepositoryProvider),
      uuidGenerator: ref.watch(uuidGeneratorProvider),
    );

@riverpod
UpdateSavingGoalUseCase updateSavingGoalUseCase(Ref ref) =>
    UpdateSavingGoalUseCase(
      repository: ref.watch(savingGoalRepositoryProvider),
    );

@riverpod
ArchiveSavingGoalUseCase archiveSavingGoalUseCase(Ref ref) =>
    ArchiveSavingGoalUseCase(
      repository: ref.watch(savingGoalRepositoryProvider),
    );

@riverpod
WatchSavingGoalsUseCase watchSavingGoalsUseCase(Ref ref) =>
    WatchSavingGoalsUseCase(
      repository: ref.watch(savingGoalRepositoryProvider),
    );

@riverpod
WatchSavingGoalAnalyticsUseCase watchSavingGoalAnalyticsUseCase(Ref ref) =>
    WatchSavingGoalAnalyticsUseCase(
      transactionRepository: ref.watch(transactionRepositoryProvider),
    );

@riverpod
GetSavingGoalsUseCase getSavingGoalsUseCase(Ref ref) =>
    GetSavingGoalsUseCase(repository: ref.watch(savingGoalRepositoryProvider));

@riverpod
AddContributionUseCase addContributionUseCase(Ref ref) =>
    AddContributionUseCase(repository: ref.watch(savingGoalRepositoryProvider));

@riverpod
CategoryRepository categoryRepository(Ref ref) => CategoryRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  categoryDao: ref.watch(categoryDaoProvider),
  outboxDao: ref.watch(outboxDaoProvider),
);

@riverpod
SaveCategoryUseCase saveCategoryUseCase(Ref ref) =>
    SaveCategoryUseCase(ref.watch(categoryRepositoryProvider));

@riverpod
DeleteCategoryUseCase deleteCategoryUseCase(Ref ref) =>
    DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider));

final rp.Provider<WatchCategoriesUseCase> watchCategoriesUseCaseProvider =
    rp.Provider<WatchCategoriesUseCase>((rp.Ref ref) {
      return WatchCategoriesUseCase(ref.watch(categoryRepositoryProvider));
    });

final rp.Provider<WatchCategoryTreeUseCase> watchCategoryTreeUseCaseProvider =
    rp.Provider<WatchCategoryTreeUseCase>((rp.Ref ref) {
      return WatchCategoryTreeUseCase(ref.watch(categoryRepositoryProvider));
    });

@riverpod
TransactionRepository transactionRepository(Ref ref) =>
    TransactionRepositoryImpl(
      database: ref.watch(appDatabaseProvider),
      transactionDao: ref.watch(transactionDaoProvider),
      savingGoalDao: ref.watch(savingGoalDaoProvider),
      goalContributionDao: ref.watch(goalContributionDaoProvider),
      outboxDao: ref.watch(outboxDaoProvider),
    );

@riverpod
BudgetRepository budgetRepository(Ref ref) => BudgetRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  budgetDao: ref.watch(budgetDaoProvider),
  budgetInstanceDao: ref.watch(budgetInstanceDaoProvider),
  outboxDao: ref.watch(outboxDaoProvider),
);

@riverpod
HomeDashboardPreferencesRepository homeDashboardPreferencesRepository(Ref ref) {
  return HomeDashboardPreferencesRepositoryImpl();
}

@riverpod
SavingGoalRepository savingGoalRepository(Ref ref) => SavingGoalRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  savingGoalDao: ref.watch(savingGoalDaoProvider),
  categoryDao: ref.watch(categoryDaoProvider),
  accountDao: ref.watch(accountDaoProvider),
  transactionDao: ref.watch(transactionDaoProvider),
  goalContributionDao: ref.watch(goalContributionDaoProvider),
  outboxDao: ref.watch(outboxDaoProvider),
  analyticsService: ref.watch(analyticsServiceProvider),
  loggerService: ref.watch(loggerServiceProvider),
  uuidGenerator: ref.watch(uuidGeneratorProvider),
);

@riverpod
RecurringTransactionsRepository recurringTransactionsRepository(Ref ref) =>
    RecurringTransactionsRepositoryImpl(
      ruleDao: ref.watch(recurringRuleDaoProvider),
      occurrenceDao: ref.watch(recurringOccurrenceDaoProvider),
      executionDao: ref.watch(recurringRuleExecutionDaoProvider),
      jobQueueDao: ref.watch(jobQueueDaoProvider),
      database: ref.watch(appDatabaseProvider),
      outboxDao: ref.watch(outboxDaoProvider),
    );

@riverpod
UpcomingPaymentsRepository upcomingPaymentsRepository(Ref ref) =>
    UpcomingPaymentsRepositoryImpl(dao: ref.watch(upcomingPaymentsDaoProvider));

@riverpod
PaymentRemindersRepository paymentRemindersRepository(Ref ref) =>
    PaymentRemindersRepositoryImpl(dao: ref.watch(paymentRemindersDaoProvider));

final rp.Provider<AddTransactionUseCase> addTransactionUseCaseProvider =
    rp.Provider<AddTransactionUseCase>((rp.Ref ref) {
      return AddTransactionUseCase(
        transactionRepository: ref.watch(transactionRepositoryProvider),
        accountRepository: ref.watch(accountRepositoryProvider),
        onTransactionCreatedUseCase: ref.watch(
          onTransactionCreatedUseCaseProvider,
        ),
      );
    });

final rp.Provider<UpdateTransactionUseCase> updateTransactionUseCaseProvider =
    rp.Provider<UpdateTransactionUseCase>((rp.Ref ref) {
      return UpdateTransactionUseCase(
        transactionRepository: ref.watch(transactionRepositoryProvider),
        accountRepository: ref.watch(accountRepositoryProvider),
      );
    });

final rp.Provider<DeleteTransactionUseCase> deleteTransactionUseCaseProvider =
    rp.Provider<DeleteTransactionUseCase>((rp.Ref ref) {
      return DeleteTransactionUseCase(
        transactionRepository: ref.watch(transactionRepositoryProvider),
        accountRepository: ref.watch(accountRepositoryProvider),
        onTransactionDeletedUseCase: ref.watch(
          onTransactionDeletedUseCaseProvider,
        ),
      );
    });

@riverpod
WatchAccountTransactionsUseCase watchAccountTransactionsUseCase(Ref ref) =>
    WatchAccountTransactionsUseCase(ref.watch(transactionRepositoryProvider));

@riverpod
WatchRecentTransactionsUseCase watchRecentTransactionsUseCase(Ref ref) =>
    WatchRecentTransactionsUseCase(ref.watch(transactionRepositoryProvider));

@riverpod
WatchMonthlyAnalyticsUseCase watchMonthlyAnalyticsUseCase(Ref ref) =>
    WatchMonthlyAnalyticsUseCase(
      transactionRepository: ref.watch(transactionRepositoryProvider),
    );

@riverpod
GroupTransactionsByDayUseCase groupTransactionsByDayUseCase(Ref ref) =>
    const GroupTransactionsByDayUseCase();

@riverpod
GetAiFinancialOverviewUseCase getAiFinancialOverviewUseCase(Ref ref) =>
    GetAiFinancialOverviewUseCase(ref.watch(aiFinancialDataRepositoryProvider));

@riverpod
WatchAiFinancialOverviewUseCase watchAiFinancialOverviewUseCase(Ref ref) =>
    WatchAiFinancialOverviewUseCase(
      ref.watch(aiFinancialDataRepositoryProvider),
    );

@riverpod
WatchRecurringRulesUseCase watchRecurringRulesUseCase(Ref ref) =>
    WatchRecurringRulesUseCase(
      ref.watch(recurringTransactionsRepositoryProvider),
    );

@riverpod
WatchUpcomingPaymentsUseCase watchUpcomingPaymentsUseCase(Ref ref) =>
    WatchUpcomingPaymentsUseCase(
      recurringRepository: ref.watch(recurringTransactionsRepositoryProvider),
    );

@riverpod
WatchUpcomingOccurrencesUseCase watchUpcomingOccurrencesUseCase(Ref ref) =>
    WatchUpcomingOccurrencesUseCase(
      ref.watch(recurringTransactionsRepositoryProvider),
    );

@riverpod
SaveRecurringRuleUseCase saveRecurringRuleUseCase(Ref ref) =>
    SaveRecurringRuleUseCase(
      ref.watch(recurringTransactionsRepositoryProvider),
    );

@riverpod
DeleteRecurringRuleUseCase deleteRecurringRuleUseCase(Ref ref) =>
    DeleteRecurringRuleUseCase(
      ref.watch(recurringTransactionsRepositoryProvider),
    );

@riverpod
ToggleRecurringRuleUseCase toggleRecurringRuleUseCase(Ref ref) =>
    ToggleRecurringRuleUseCase(
      ref.watch(recurringTransactionsRepositoryProvider),
    );

@riverpod
RegenerateRuleWindowUseCase regenerateRuleWindowUseCase(Ref ref) =>
    RegenerateRuleWindowUseCase(
      ref.watch(recurringTransactionsRepositoryProvider),
      ref.watch(recurringRuleEngineProvider),
    );

@riverpod
RecurringWindowService recurringWindowService(Ref ref) =>
    RecurringWindowService(
      repository: ref.watch(recurringTransactionsRepositoryProvider),
      engine: ref.watch(recurringRuleEngineProvider),
    );

@riverpod
RecurringWorkScheduler recurringWorkScheduler(Ref ref) =>
    RecurringWorkScheduler(
      workmanager: ref.watch(workmanagerProvider),
      logger: ref.watch(loggerServiceProvider),
    );

@riverpod
ExactAlarmPermissionService exactAlarmPermissionService(Ref ref) =>
    ExactAlarmPermissionService();

@riverpod
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  profileDao: ref.watch(profileDaoProvider),
  remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  outboxDao: ref.watch(outboxDaoProvider),
);

@riverpod
ProfileAvatarRepository profileAvatarRepository(Ref ref) =>
    ProfileAvatarRepositoryImpl(
      remoteDataSource: ref.watch(avatarRemoteDataSourceProvider),
    );

@riverpod
UserProgressRepository userProgressRepository(Ref ref) {
  final UserProgressRepositoryImpl repository = UserProgressRepositoryImpl(
    transactionDao: ref.watch(transactionDaoProvider),
    remoteDataSource: ref.watch(userProgressRemoteDataSourceProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
}

@riverpod
UpdateProfileUseCase updateProfileUseCase(Ref ref) =>
    UpdateProfileUseCaseImpl(repository: ref.watch(profileRepositoryProvider));

@riverpod
RecomputeUserProgressUseCase recomputeUserProgressUseCase(Ref ref) =>
    RecomputeUserProgressUseCase(
      repository: ref.watch(userProgressRepositoryProvider),
      levelPolicy: ref.watch(levelPolicyProvider),
      authRepository: ref.watch(authRepositoryProvider),
    );

@riverpod
OnTransactionCreatedUseCase onTransactionCreatedUseCase(Ref ref) =>
    OnTransactionCreatedUseCase(
      recomputeUserProgressUseCase: ref.watch(
        recomputeUserProgressUseCaseProvider,
      ),
      levelPolicy: ref.watch(levelPolicyProvider),
    );

@riverpod
OnTransactionDeletedUseCase onTransactionDeletedUseCase(Ref ref) =>
    OnTransactionDeletedUseCase(
      recomputeUserProgressUseCase: ref.watch(
        recomputeUserProgressUseCaseProvider,
      ),
    );

@riverpod
UpdateProfileAvatarUseCase updateProfileAvatarUseCase(Ref ref) =>
    UpdateProfileAvatarUseCase(
      avatarRepository: ref.watch(profileAvatarRepositoryProvider),
      profileRepository: ref.watch(profileRepositoryProvider),
    );

@riverpod
SyncService syncService(Ref ref) {
  final SyncService service = SyncService(
    outboxDao: ref.watch(outboxDaoProvider),
    accountRemoteDataSource: ref.watch(accountRemoteDataSourceProvider),
    categoryRemoteDataSource: ref.watch(categoryRemoteDataSourceProvider),
    transactionRemoteDataSource: ref.watch(transactionRemoteDataSourceProvider),
    profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    budgetRemoteDataSource: ref.watch(budgetRemoteDataSourceProvider),
    budgetInstanceRemoteDataSource: ref.watch(
      budgetInstanceRemoteDataSourceProvider,
    ),
    savingGoalRemoteDataSource: ref.watch(savingGoalRemoteDataSourceProvider),
    recurringRuleRemoteDataSource: ref.watch(
      recurringRuleRemoteDataSourceProvider,
    ),
    firebaseAuth: ref.watch(firebaseAuthProvider),
    connectivity: ref.watch(connectivityProvider),
  );
  unawaited(service.initialize());
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  firebaseAuth: ref.watch(firebaseAuthProvider),
  loggerService: ref.watch(loggerServiceProvider),
  analyticsService: ref.watch(analyticsServiceProvider),
);

@riverpod
AuthSyncService authSyncService(Ref ref) => AuthSyncService(
  database: ref.watch(appDatabaseProvider),
  outboxDao: ref.watch(outboxDaoProvider),
  accountDao: ref.watch(accountDaoProvider),
  categoryDao: ref.watch(categoryDaoProvider),
  transactionDao: ref.watch(transactionDaoProvider),
  budgetDao: ref.watch(budgetDaoProvider),
  budgetInstanceDao: ref.watch(budgetInstanceDaoProvider),
  savingGoalDao: ref.watch(savingGoalDaoProvider),
  recurringRuleDao: ref.watch(recurringRuleDaoProvider),
  profileDao: ref.watch(profileDaoProvider),
  accountRemoteDataSource: ref.watch(accountRemoteDataSourceProvider),
  categoryRemoteDataSource: ref.watch(categoryRemoteDataSourceProvider),
  transactionRemoteDataSource: ref.watch(transactionRemoteDataSourceProvider),
  budgetRemoteDataSource: ref.watch(budgetRemoteDataSourceProvider),
  budgetInstanceRemoteDataSource: ref.watch(
    budgetInstanceRemoteDataSourceProvider,
  ),
  savingGoalRemoteDataSource: ref.watch(savingGoalRemoteDataSourceProvider),
  recurringRuleRemoteDataSource: ref.watch(
    recurringRuleRemoteDataSourceProvider,
  ),
  profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  firestore: ref.watch(firestoreProvider),
  loggerService: ref.watch(loggerServiceProvider),
  analyticsService: ref.watch(analyticsServiceProvider),
);
