import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod/riverpod.dart' as rp;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:kopim/core/application/firebase_availability.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/database/database_factory.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/utils/web_platform_utils.dart';
import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/core/services/exact_alarm_permission_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notification_fallback_presenter.dart';
import 'package:kopim/core/services/notifications_gateway.dart';
import 'package:kopim/core/services/push_permission_service.dart';
import 'package:kopim/core/services/sync/sync_data_sanitizer.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/ai/data/local/ai_assistant_tool_dao.dart';
import 'package:kopim/features/ai/data/repositories/ai_assistant_repository_impl.dart';
import 'package:kopim/features/ai/data/repositories/ai_financial_data_repository_impl.dart';
import 'package:kopim/features/ai/data/tools/ai_assistant_tool_router.dart';
import 'package:kopim/features/ai/data/tools/ai_assistant_tools.dart';
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
import 'package:kopim/features/profile/data/offline_auth_repository.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/profile_avatar_repository_impl.dart';
import 'package:kopim/features/profile/data/profile_repository_impl.dart';
import 'package:kopim/features/profile/data/remote/avatar_remote_data_source.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/data/remote/user_progress_remote_data_source.dart';
import 'package:kopim/features/profile/data/services/profile_sync_error_reporter_logger.dart';
import 'package:kopim/features/profile/data/user_progress_repository_impl.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';
import 'package:kopim/features/profile/domain/services/profile_sync_error_reporter.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_created_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_deleted_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/recompute_user_progress_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_avatar_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case_impl.dart';
import 'package:kopim/features/settings/data/repositories/export_data_repository_impl.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/settings/data/services/export_file_saver/export_file_saver_factory.dart';
import 'package:kopim/features/settings/data/services/import_file_picker/import_file_picker_factory.dart';
import 'package:kopim/features/settings/domain/repositories/export_data_repository.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_decoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_encoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_decoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_encoder.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';
import 'package:kopim/features/settings/domain/use_cases/export_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/use_cases/export_user_data_use_case_impl.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case_impl.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case_impl.dart';

import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/delete_transaction_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/update_transaction_use_case.dart';
import 'package:uuid/uuid.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_account_monthly_totals_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_account_transactions_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_recent_transactions_use_case.dart';
import 'package:kopim/features/home/data/repositories/home_dashboard_preferences_repository_impl.dart';
import 'package:kopim/features/home/domain/repositories/home_dashboard_preferences_repository.dart';
import 'package:kopim/features/home/domain/use_cases/group_transactions_by_day_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/add_credit_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/add_credit_card_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/add_debt_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/delete_credit_card_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/delete_credit_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/delete_debt_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/get_credit_card_by_account_id_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/update_credit_card_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/update_credit_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/update_debt_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/watch_credit_cards_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/watch_credits_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/watch_debts_use_case.dart';
import 'package:kopim/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart';
import 'package:kopim/firebase_options.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/debt_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_card_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/repositories/payment_reminders_repository_impl.dart';
import 'package:kopim/features/upcoming_payments/data/drift/repositories/upcoming_payments_repository_impl.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/payment_reminder_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/upcoming_payment_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/repositories/credit_repository_impl.dart';
import 'package:kopim/features/credits/data/repositories/debt_repository_impl.dart';
import 'package:kopim/features/credits/data/repositories/credit_card_repository_impl.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/repositories/debt_repository.dart';
import 'package:kopim/features/credits/domain/repositories/credit_card_repository.dart';

part 'injectors.g.dart';

const List<String> _kDefaultAiModelFallbacks = <String>[];

@riverpod
LoggerService loggerService(Ref ref) => LoggerService();

@riverpod
AnalyticsService analyticsService(Ref ref) => const AnalyticsService();

@Riverpod(keepAlive: true)
Future<void> firebaseInitialization(Ref ref) async {
  final LoggerService logger = ref.watch(loggerServiceProvider);
  final FirebaseAvailabilityNotifier availability = ref.read(
    firebaseAvailabilityProvider.notifier,
  );
  final bool isWebIosSafari = isWebSafari();
  Future<void>.microtask(availability.setUnknown);

  if (_hasFirebaseAppsSafely(logger: logger, isWebIosSafari: isWebIosSafari)) {
    Future<void>.microtask(availability.setAvailable);
    return;
  }

  final FirebaseOptions options;
  try {
    options = DefaultFirebaseOptions.currentPlatform;
  } catch (error, stackTrace) {
    if (isWebIosSafari) {
      Future<void>.microtask(
        () => availability.setUnavailable(
          'Облачные функции недоступны в этом браузере. Вход и синхронизация выключены, данные сохраняются локально. Есть риск потери данных — сделайте выгрузку в настройках приложения.',
        ),
      );
      logger.logError('Сбой подготовки Firebase настроек (web): $error', error);
      return;
    }
    logger.logError('Сбой подготовки Firebase настроек', error);
    Error.throwWithStackTrace(error, stackTrace);
  }

  try {
    await Firebase.initializeApp(options: options);
    Future<void>.microtask(availability.setAvailable);
  } on FirebaseException catch (error, stackTrace) {
    if (error.code == 'duplicate-app') {
      Future<void>.microtask(availability.setAvailable);
      return;
    }
    if (isWebIosSafari) {
      Future<void>.microtask(
        () => availability.setUnavailable(
          'Облачные функции недоступны в этом браузере. Вход и синхронизация выключены, данные сохраняются локально. Есть риск потери данных — сделайте выгрузку в настройках приложения.',
        ),
      );
      logger.logError(
        'Сбой инициализации Firebase (web): ${error.code}',
        error,
      );
      return;
    }
    logger.logError('Сбой инициализации Firebase: ${error.code}', error);
    Error.throwWithStackTrace(error, stackTrace);
  } catch (error, stackTrace) {
    if (isWebIosSafari) {
      Future<void>.microtask(
        () => availability.setUnavailable(
          'Облачные функции недоступны в этом браузере. Вход и синхронизация выключены, данные сохраняются локально. Есть риск потери данных — сделайте выгрузку в настройках приложения.',
        ),
      );
      logger.logError('Неожиданная ошибка инициализации Firebase (web)', error);
      return;
    }
    logger.logError('Неожиданная ошибка инициализации Firebase', error);
    Error.throwWithStackTrace(error, stackTrace);
  }
}

/// На iOS Web доступ к Firebase.apps может падать из-за JS interop, поэтому
/// избегаем этого вызова и всегда инициализируем Firebase вручную.
bool _hasFirebaseAppsSafely({
  required LoggerService logger,
  required bool isWebIosSafari,
}) {
  if (isWebIosSafari) {
    return false;
  }
  try {
    return Firebase.apps.isNotEmpty;
  } catch (error) {
    logger.logError('Firebase.apps недоступен', error);
    if (isWebIosSafari) {
      return false;
    }
    rethrow;
  }
}

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  ref.watch(firebaseInitializationProvider).requireValue;
  final FirebaseFirestore instance = FirebaseFirestore.instance;
  if (kIsWeb) {
    try {
      instance.settings = const Settings(persistenceEnabled: false);
    } catch (_) {
      // Ignore if settings are already set or locked
    }
  }
  return instance;
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) {
  ref.watch(firebaseInitializationProvider).requireValue;
  return FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(Ref ref) {
  ref.watch(firebaseInitializationProvider).requireValue;
  return FirebaseStorage.instance;
}

@Riverpod(keepAlive: true)
FirebaseRemoteConfig firebaseRemoteConfig(Ref ref) {
  ref.watch(firebaseInitializationProvider).requireValue;
  return FirebaseRemoteConfig.instance;
}

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
  final AppDatabase database = constructDb();
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
ExportDataRepository exportDataRepository(Ref ref) => ExportDataRepositoryImpl(
  accountDao: ref.watch(accountDaoProvider),
  transactionDao: ref.watch(transactionDaoProvider),
  categoryDao: ref.watch(categoryDaoProvider),
);

@riverpod
ExportBundleJsonEncoder exportBundleJsonEncoder(Ref ref) =>
    const ExportBundleJsonEncoder();

@riverpod
ExportBundleJsonDecoder exportBundleJsonDecoder(Ref ref) =>
    const ExportBundleJsonDecoder();

@riverpod
ExportFileSaver exportFileSaver(Ref ref) => createExportFileSaver();

@riverpod
ImportFilePicker importFilePicker(Ref ref) => createImportFilePicker();

@riverpod
PrepareExportBundleUseCase prepareExportBundleUseCase(Ref ref) =>
    PrepareExportBundleUseCaseImpl(
      repository: ref.watch(exportDataRepositoryProvider),
    );

@riverpod
ExportUserDataUseCase exportUserDataUseCase(Ref ref) =>
    ExportUserDataUseCaseImpl(
      prepareExportBundle: ref.watch(prepareExportBundleUseCaseProvider),
      jsonEncoder: ref.watch(exportBundleJsonEncoderProvider),
      csvEncoder: const ExportBundleCsvEncoder(),
      fileSaver: ref.watch(exportFileSaverProvider),
    );

@riverpod
ImportDataRepository importDataRepository(Ref ref) => ImportDataRepositoryImpl(
  accountDao: ref.watch(accountDaoProvider),
  categoryDao: ref.watch(categoryDaoProvider),
  transactionDao: ref.watch(transactionDaoProvider),
);

@riverpod
ImportUserDataUseCase importUserDataUseCase(Ref ref) =>
    ImportUserDataUseCaseImpl(
      filePicker: ref.watch(importFilePickerProvider),
      jsonDecoder: ref.watch(exportBundleJsonDecoderProvider),
      csvDecoder: const ExportBundleCsvDecoder(),
      repository: ref.watch(importDataRepositoryProvider),
    );

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
CreditDao creditDao(Ref ref) => CreditDao(ref.watch(appDatabaseProvider));

@riverpod
CreditCardDao creditCardDao(Ref ref) =>
    CreditCardDao(ref.watch(appDatabaseProvider));

final rp.Provider<DebtDao> debtDaoProvider = rp.Provider<DebtDao>((rp.Ref ref) {
  return DebtDao(ref.watch(appDatabaseProvider));
});

@riverpod
UpcomingPaymentsDao upcomingPaymentsDao(Ref ref) =>
    UpcomingPaymentsDao(ref.watch(appDatabaseProvider));

@riverpod
PaymentRemindersDao paymentRemindersDao(Ref ref) =>
    PaymentRemindersDao(ref.watch(appDatabaseProvider));

final rp.Provider<UpcomingPaymentRemoteDataSource>
upcomingPaymentRemoteDataSourceProvider =
    rp.Provider<UpcomingPaymentRemoteDataSource>((rp.Ref ref) {
      return UpcomingPaymentRemoteDataSource(ref.watch(firestoreProvider));
    });

final rp.Provider<PaymentReminderRemoteDataSource>
paymentReminderRemoteDataSourceProvider =
    rp.Provider<PaymentReminderRemoteDataSource>((rp.Ref ref) {
      return PaymentReminderRemoteDataSource(ref.watch(firestoreProvider));
    });

final rp.Provider<CreditRemoteDataSource> creditRemoteDataSourceProvider =
    rp.Provider<CreditRemoteDataSource>((rp.Ref ref) {
      return CreditRemoteDataSource(ref.watch(firestoreProvider));
    });

final rp.Provider<CreditCardRemoteDataSource>
creditCardRemoteDataSourceProvider =
    rp.Provider<CreditCardRemoteDataSource>((rp.Ref ref) {
      return CreditCardRemoteDataSource(ref.watch(firestoreProvider));
    });

final rp.Provider<DebtRemoteDataSource> debtRemoteDataSourceProvider =
    rp.Provider<DebtRemoteDataSource>((rp.Ref ref) {
      return DebtRemoteDataSource(ref.watch(firestoreProvider));
    });

@riverpod
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin(Ref ref) {
  if (kIsWeb) {
    return null;
  }
  return FlutterLocalNotificationsPlugin();
}

@riverpod
NotificationFallbackPresenter notificationFallbackPresenter(Ref ref) {
  final NotificationFallbackPresenter presenter = kIsWeb
      ? StreamNotificationFallbackPresenter()
      : const NullNotificationFallbackPresenter();
  ref.onDispose(presenter.dispose);
  return presenter;
}

@riverpod
PushPermissionService pushPermissionService(Ref ref) {
  final PushPermissionService service = createPushPermissionService(
    logger: ref.watch(loggerServiceProvider),
  );
  return service;
}

@riverpod
NotificationsGateway notificationsGateway(Ref ref) {
  final NotificationsGateway gateway = createNotificationsGateway(
    plugin: ref.watch(flutterLocalNotificationsPluginProvider),
    logger: ref.watch(loggerServiceProvider),
    exactAlarmPermissionService: ref.watch(exactAlarmPermissionServiceProvider),
    fallbackPresenter: ref.watch(notificationFallbackPresenterProvider),
    pushPermissionService: kIsWeb
        ? ref.watch(pushPermissionServiceProvider)
        : null,
  );
  ref.onDispose(gateway.dispose);
  return gateway;
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
  final AiAssistantToolRouter toolRouter = AiAssistantToolRouter(
    toolDao: AiAssistantToolDao(ref.watch(appDatabaseProvider)),
    analyticsDao: ref.watch(aiAnalyticsDaoProvider),
    loggerService: ref.watch(loggerServiceProvider),
  );
  const AiAssistantToolsRegistry toolsRegistry = AiAssistantToolsRegistry();
  return AiAssistantRepositoryImpl(
    service: ref.watch(aiAssistantServiceProvider),
    financialDataRepository: ref.watch(aiFinancialDataRepositoryProvider),
    toolRouter: toolRouter,
    toolsRegistry: toolsRegistry,
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
CreditRepository creditRepository(Ref ref) => CreditRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  creditDao: ref.watch(creditDaoProvider),
  outboxDao: ref.watch(outboxDaoProvider),
);

@riverpod
CreditCardRepository creditCardRepository(Ref ref) =>
    CreditCardRepositoryImpl(
      database: ref.watch(appDatabaseProvider),
      creditCardDao: ref.watch(creditCardDaoProvider),
      outboxDao: ref.watch(outboxDaoProvider),
    );

final rp.Provider<DebtRepository> debtRepositoryProvider =
    rp.Provider<DebtRepository>((rp.Ref ref) {
      return DebtRepositoryImpl(
        database: ref.watch(appDatabaseProvider),
        debtDao: ref.watch(debtDaoProvider),
        outboxDao: ref.watch(outboxDaoProvider),
      );
    });

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
AddCreditUseCase addCreditUseCase(Ref ref) => AddCreditUseCase(
  creditRepository: ref.watch(creditRepositoryProvider),
  accountRepository: ref.watch(accountRepositoryProvider),
  saveCategoryUseCase: ref.watch(saveCategoryUseCaseProvider),
  uuid: ref.watch(uuidGeneratorProvider),
);

@riverpod
AddCreditCardUseCase addCreditCardUseCase(Ref ref) =>
    AddCreditCardUseCase(ref.watch(creditCardRepositoryProvider));

@riverpod
UpdateCreditCardUseCase updateCreditCardUseCase(Ref ref) =>
    UpdateCreditCardUseCase(ref.watch(creditCardRepositoryProvider));

@riverpod
DeleteCreditCardUseCase deleteCreditCardUseCase(Ref ref) =>
    DeleteCreditCardUseCase(ref.watch(creditCardRepositoryProvider));

@riverpod
GetCreditCardByAccountIdUseCase getCreditCardByAccountIdUseCase(Ref ref) =>
    GetCreditCardByAccountIdUseCase(ref.watch(creditCardRepositoryProvider));

final rp.Provider<UpdateCreditUseCase> updateCreditUseCaseProvider =
    rp.Provider<UpdateCreditUseCase>((rp.Ref ref) {
      return UpdateCreditUseCase(
        creditRepository: ref.watch(creditRepositoryProvider),
        accountRepository: ref.watch(accountRepositoryProvider),
        categoryRepository: ref.watch(categoryRepositoryProvider),
        saveCategoryUseCase: ref.watch(saveCategoryUseCaseProvider),
      );
    });

@riverpod
DeleteCreditUseCase deleteCreditUseCase(Ref ref) => DeleteCreditUseCase(
  ref.watch(creditRepositoryProvider),
  ref.watch(deleteAccountUseCaseProvider),
  ref.watch(deleteCategoryUseCaseProvider),
);

@riverpod
WatchCreditsUseCase watchCreditsUseCase(Ref ref) =>
    WatchCreditsUseCase(ref.watch(creditRepositoryProvider));

@riverpod
WatchCreditCardsUseCase watchCreditCardsUseCase(Ref ref) =>
    WatchCreditCardsUseCase(ref.watch(creditCardRepositoryProvider));

final rp.Provider<AddDebtUseCase> addDebtUseCaseProvider =
    rp.Provider<AddDebtUseCase>((rp.Ref ref) {
      return AddDebtUseCase(
        debtRepository: ref.watch(debtRepositoryProvider),
        categoryRepository: ref.watch(categoryRepositoryProvider),
        saveCategoryUseCase: ref.watch(saveCategoryUseCaseProvider),
        uuid: ref.watch(uuidGeneratorProvider),
      );
    });

final rp.Provider<UpdateDebtUseCase> updateDebtUseCaseProvider =
    rp.Provider<UpdateDebtUseCase>((rp.Ref ref) {
      return UpdateDebtUseCase(
        debtRepository: ref.watch(debtRepositoryProvider),
      );
    });

final rp.Provider<DeleteDebtUseCase> deleteDebtUseCaseProvider =
    rp.Provider<DeleteDebtUseCase>((rp.Ref ref) {
      return DeleteDebtUseCase(ref.watch(debtRepositoryProvider));
    });

final rp.Provider<WatchDebtsUseCase> watchDebtsUseCaseProvider =
    rp.Provider<WatchDebtsUseCase>((rp.Ref ref) {
      return WatchDebtsUseCase(ref.watch(debtRepositoryProvider));
    });

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
UpcomingPaymentsRepository upcomingPaymentsRepository(Ref ref) =>
    UpcomingPaymentsRepositoryImpl(
      database: ref.watch(appDatabaseProvider),
      dao: ref.watch(upcomingPaymentsDaoProvider),
      outboxDao: ref.watch(outboxDaoProvider),
    );

@riverpod
PaymentRemindersRepository paymentRemindersRepository(Ref ref) =>
    PaymentRemindersRepositoryImpl(
      database: ref.watch(appDatabaseProvider),
      dao: ref.watch(paymentRemindersDaoProvider),
      outboxDao: ref.watch(outboxDaoProvider),
    );

final rp.Provider<AddTransactionUseCase> addTransactionUseCaseProvider =
    rp.Provider<AddTransactionUseCase>((rp.Ref ref) {
      return AddTransactionUseCase(
        transactionRepository: ref.watch(transactionRepositoryProvider),
        accountRepository: ref.watch(accountRepositoryProvider),
        creditRepository: ref.watch(creditRepositoryProvider),
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
        creditRepository: ref.watch(creditRepositoryProvider),
      );
    });

final rp.Provider<DeleteTransactionUseCase> deleteTransactionUseCaseProvider =
    rp.Provider<DeleteTransactionUseCase>((rp.Ref ref) {
      return DeleteTransactionUseCase(
        transactionRepository: ref.watch(transactionRepositoryProvider),
        accountRepository: ref.watch(accountRepositoryProvider),
        creditRepository: ref.watch(creditRepositoryProvider),
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
WatchAccountMonthlyTotalsUseCase watchAccountMonthlyTotalsUseCase(Ref ref) =>
    WatchAccountMonthlyTotalsUseCase(ref.watch(transactionRepositoryProvider));

@riverpod
WatchMonthlyAnalyticsUseCase watchMonthlyAnalyticsUseCase(Ref ref) =>
    WatchMonthlyAnalyticsUseCase(
      transactionRepository: ref.watch(transactionRepositoryProvider),
      categoryRepository: ref.watch(categoryRepositoryProvider),
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

final rp.Provider<ProfileSyncErrorReporter> profileSyncErrorReporterProvider =
    rp.Provider<ProfileSyncErrorReporter>((rp.Ref ref) {
      return LoggerProfileSyncErrorReporter(
        logger: ref.watch(loggerServiceProvider),
      );
    });

@riverpod
UpdateProfileUseCase updateProfileUseCase(Ref ref) =>
    UpdateProfileUseCaseImpl(repository: ref.watch(profileRepositoryProvider));

@riverpod
RecomputeUserProgressUseCase recomputeUserProgressUseCase(Ref ref) =>
    RecomputeUserProgressUseCase(
      repository: ref.watch(userProgressRepositoryProvider),
      levelPolicy: ref.watch(levelPolicyProvider),
      authRepository: ref.watch(authRepositoryProvider),
      syncErrorReporter: ref.watch(profileSyncErrorReporterProvider),
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
    debtRemoteDataSource: ref.watch(debtRemoteDataSourceProvider),
    profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    budgetRemoteDataSource: ref.watch(budgetRemoteDataSourceProvider),
    budgetInstanceRemoteDataSource: ref.watch(
      budgetInstanceRemoteDataSourceProvider,
    ),
    savingGoalRemoteDataSource: ref.watch(savingGoalRemoteDataSourceProvider),
    upcomingPaymentRemoteDataSource: ref.watch(
      upcomingPaymentRemoteDataSourceProvider,
    ),
    paymentReminderRemoteDataSource: ref.watch(
      paymentReminderRemoteDataSourceProvider,
    ),
    firebaseAuth: ref.watch(firebaseAuthProvider),
    connectivity: ref.watch(connectivityProvider),
  );
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final FirebaseAvailabilityState availability = ref.watch(
    firebaseAvailabilityProvider,
  );
  if (kIsWeb && availability.isAvailable == false) {
    final OfflineAuthRepository repository = OfflineAuthRepository(
      loggerService: ref.watch(loggerServiceProvider),
    );
    ref.onDispose(repository.dispose);
    return repository;
  }
  return AuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    loggerService: ref.watch(loggerServiceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
  );
}

@riverpod
SyncDataSanitizer syncDataSanitizer(Ref ref) =>
    SyncDataSanitizer(logger: ref.watch(loggerServiceProvider));

@riverpod
AuthSyncService authSyncService(Ref ref) => AuthSyncService(
  database: ref.watch(appDatabaseProvider),
  outboxDao: ref.watch(outboxDaoProvider),
  accountDao: ref.watch(accountDaoProvider),
  categoryDao: ref.watch(categoryDaoProvider),
  transactionDao: ref.watch(transactionDaoProvider),
  creditCardDao: ref.watch(creditCardDaoProvider),
  creditDao: ref.watch(creditDaoProvider),
  debtDao: ref.watch(debtDaoProvider),
  budgetDao: ref.watch(budgetDaoProvider),
  budgetInstanceDao: ref.watch(budgetInstanceDaoProvider),
  savingGoalDao: ref.watch(savingGoalDaoProvider),
  upcomingPaymentsDao: ref.watch(upcomingPaymentsDaoProvider),
  paymentRemindersDao: ref.watch(paymentRemindersDaoProvider),
  profileDao: ref.watch(profileDaoProvider),
  accountRemoteDataSource: ref.watch(accountRemoteDataSourceProvider),
  categoryRemoteDataSource: ref.watch(categoryRemoteDataSourceProvider),
  transactionRemoteDataSource: ref.watch(transactionRemoteDataSourceProvider),
  creditCardRemoteDataSource: ref.watch(creditCardRemoteDataSourceProvider),
  creditRemoteDataSource: ref.watch(creditRemoteDataSourceProvider),
  debtRemoteDataSource: ref.watch(debtRemoteDataSourceProvider),
  budgetRemoteDataSource: ref.watch(budgetRemoteDataSourceProvider),
  budgetInstanceRemoteDataSource: ref.watch(
    budgetInstanceRemoteDataSourceProvider,
  ),
  savingGoalRemoteDataSource: ref.watch(savingGoalRemoteDataSourceProvider),
  upcomingPaymentRemoteDataSource: ref.watch(
    upcomingPaymentRemoteDataSourceProvider,
  ),
  paymentReminderRemoteDataSource: ref.watch(
    paymentReminderRemoteDataSourceProvider,
  ),
  profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  firestore: ref.watch(firestoreProvider),
  loggerService: ref.watch(loggerServiceProvider),
  analyticsService: ref.watch(analyticsServiceProvider),
  dataSanitizer: ref.watch(syncDataSanitizerProvider),
);
