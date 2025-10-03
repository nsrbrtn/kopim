import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod/riverpod.dart' as rp;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart';
import 'package:kopim/features/categories/data/repositories/category_repository_impl.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/watch_categories_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/watch_category_tree_use_case.dart';
import 'package:kopim/features/profile/data/auth_repository_impl.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/profile_repository_impl.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
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
import 'package:kopim/features/home/domain/use_cases/group_transactions_by_day_use_case.dart';
import 'package:kopim/features/recurring_transactions/data/repositories/recurring_transactions_repository_impl.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_notification_service.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_window_service.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_work_scheduler.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/job_queue_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_occurrence_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_dao.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_engine.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/delete_recurring_rule_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/regenerate_rule_window_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/save_recurring_rule_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/toggle_recurring_rule_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/watch_recurring_rules_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/watch_upcoming_occurrences_use_case.dart';

part 'injectors.g.dart';

@riverpod
LoggerService loggerService(Ref ref) => LoggerService();

@riverpod
AnalyticsService analyticsService(Ref ref) => AnalyticsService();

@riverpod
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
GoogleSignIn googleSignIn(Ref ref) => GoogleSignIn.instance;

@riverpod
Connectivity connectivity(Ref ref) => Connectivity();

@riverpod
Uuid uuidGenerator(Ref ref) => const Uuid();

@riverpod
AppDatabase appDatabase(Ref ref) => AppDatabase();

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
ProfileDao profileDao(Ref ref) => ProfileDao(ref.watch(appDatabaseProvider));

@riverpod
RecurringRuleDao recurringRuleDao(Ref ref) =>
    RecurringRuleDao(ref.watch(appDatabaseProvider));

@riverpod
RecurringOccurrenceDao recurringOccurrenceDao(Ref ref) =>
    RecurringOccurrenceDao(ref.watch(appDatabaseProvider));

@riverpod
JobQueueDao jobQueueDao(Ref ref) => JobQueueDao(ref.watch(appDatabaseProvider));

@riverpod
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin(Ref ref) =>
    FlutterLocalNotificationsPlugin();

@riverpod
Workmanager workmanager(Ref ref) => Workmanager();

@riverpod
RecurringRuleEngine recurringRuleEngine(Ref ref) => RecurringRuleEngine();

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
RecurringNotificationService recurringNotificationService(Ref ref) =>
    RecurringNotificationService(
      ref.watch(flutterLocalNotificationsPluginProvider),
    );

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
WatchAccountsUseCase watchAccountsUseCase(Ref ref) =>
    WatchAccountsUseCase(ref.watch(accountRepositoryProvider));

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
      outboxDao: ref.watch(outboxDaoProvider),
    );

@riverpod
RecurringTransactionsRepository recurringTransactionsRepository(Ref ref) =>
    RecurringTransactionsRepositoryImpl(
      ruleDao: ref.watch(recurringRuleDaoProvider),
      occurrenceDao: ref.watch(recurringOccurrenceDaoProvider),
      jobQueueDao: ref.watch(jobQueueDaoProvider),
      database: ref.watch(appDatabaseProvider),
    );

final rp.Provider<AddTransactionUseCase> addTransactionUseCaseProvider =
    rp.Provider<AddTransactionUseCase>((rp.Ref ref) {
      return AddTransactionUseCase(
        transactionRepository: ref.watch(transactionRepositoryProvider),
        accountRepository: ref.watch(accountRepositoryProvider),
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
WatchRecurringRulesUseCase watchRecurringRulesUseCase(Ref ref) =>
    WatchRecurringRulesUseCase(
      ref.watch(recurringTransactionsRepositoryProvider),
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
      notificationService: ref.watch(recurringNotificationServiceProvider),
    );

@riverpod
RecurringWorkScheduler recurringWorkScheduler(Ref ref) =>
    RecurringWorkScheduler(
      workmanager: ref.watch(workmanagerProvider),
      logger: ref.watch(loggerServiceProvider),
    );

@riverpod
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  profileDao: ref.watch(profileDaoProvider),
  remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  outboxDao: ref.watch(outboxDaoProvider),
);

@riverpod
UpdateProfileUseCase updateProfileUseCase(Ref ref) => UpdateProfileUseCaseImpl(
  repository: ref.watch(profileRepositoryProvider),
  analyticsService: ref.watch(analyticsServiceProvider),
);

@riverpod
SyncService syncService(Ref ref) {
  final SyncService service = SyncService(
    outboxDao: ref.watch(outboxDaoProvider),
    accountRemoteDataSource: ref.watch(accountRemoteDataSourceProvider),
    categoryRemoteDataSource: ref.watch(categoryRemoteDataSourceProvider),
    transactionRemoteDataSource: ref.watch(transactionRemoteDataSourceProvider),
    profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
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
  googleSignIn: ref.watch(googleSignInProvider),
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
  profileDao: ref.watch(profileDaoProvider),
  accountRemoteDataSource: ref.watch(accountRemoteDataSourceProvider),
  categoryRemoteDataSource: ref.watch(categoryRemoteDataSourceProvider),
  transactionRemoteDataSource: ref.watch(transactionRemoteDataSourceProvider),
  profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  firestore: ref.watch(firestoreProvider),
  loggerService: ref.watch(loggerServiceProvider),
  analyticsService: ref.watch(analyticsServiceProvider),
);
