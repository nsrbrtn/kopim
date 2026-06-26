import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_integrity_service.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';

import 'package:riverpod/riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';

typedef LocalToCloudMigrationEntityUploader =
    Future<void> Function(String uid, Object entity);

enum LocalToCloudMigrationUploadStatus { succeeded, blocked, failed }

enum LocalToCloudMigrationUploadBlockReason {
  missingPreparedState,
  invalidPreparedState,
  planMismatch,
}

class LocalToCloudMigrationUploadResult {
  const LocalToCloudMigrationUploadResult._({
    required this.status,
    this.blockReason,
    this.message,
    this.uploadedRowCountsByFamily = const <String, int>{},
  });

  const LocalToCloudMigrationUploadResult.succeeded({
    required Map<String, int> uploadedRowCountsByFamily,
    String? message,
  }) : this._(
         status: LocalToCloudMigrationUploadStatus.succeeded,
         uploadedRowCountsByFamily: uploadedRowCountsByFamily,
         message: message,
       );

  const LocalToCloudMigrationUploadResult.blocked(
    LocalToCloudMigrationUploadBlockReason reason, {
    String? message,
  }) : this._(
         status: LocalToCloudMigrationUploadStatus.blocked,
         blockReason: reason,
         message: message,
       );

  const LocalToCloudMigrationUploadResult.failed({
    String? message,
    Map<String, int> uploadedRowCountsByFamily = const <String, int>{},
  }) : this._(
         status: LocalToCloudMigrationUploadStatus.failed,
         message: message,
         uploadedRowCountsByFamily: uploadedRowCountsByFamily,
       );

  final LocalToCloudMigrationUploadStatus status;
  final LocalToCloudMigrationUploadBlockReason? blockReason;
  final String? message;
  final Map<String, int> uploadedRowCountsByFamily;
}

class LocalToCloudMigrationUploadService {
  LocalToCloudMigrationUploadService({
    required FirebaseFirestore firestore,
    required LocalToCloudMigrationStateRepository migrationStateRepository,
    required PrepareExportBundleUseCase prepareExportBundleUseCase,
    required Map<String, LocalToCloudMigrationEntityUploader> uploaders,
    required LoggerService logger,
  }) : _firestore = firestore,
       _migrationStateRepository = migrationStateRepository,
       _prepareExportBundleUseCase = prepareExportBundleUseCase,
       _uploaders =
           Map<String, LocalToCloudMigrationEntityUploader>.unmodifiable(
             uploaders,
           ),
       _logger = logger;

  static const List<String> uploadOrder = <String>[
    'accounts',
    'categories',
    'tags',
    'transactions',
    'transaction_tags',
    'budgets',
    'budget_instances',
    'saving_goals',
    'credits',
    'credit_cards',
    'debts',
    'credit_payment_schedules',
    'credit_payment_groups',
    'upcoming_payments',
    'payment_reminders',
  ];

  final FirebaseFirestore _firestore;
  final LocalToCloudMigrationStateRepository _migrationStateRepository;
  final PrepareExportBundleUseCase _prepareExportBundleUseCase;
  final Map<String, LocalToCloudMigrationEntityUploader> _uploaders;
  final LoggerService _logger;

  Future<LocalToCloudMigrationUploadResult> uploadPreparedMigration({
    required String uid,
  }) async {
    final LocalToCloudMigrationState? existingState =
        await _migrationStateRepository.getStateForUid(uid);
    if (existingState == null) {
      return const LocalToCloudMigrationUploadResult.blocked(
        LocalToCloudMigrationUploadBlockReason.missingPreparedState,
        message: 'Для migrateLocalToCloud нет подготовленного durable state.',
      );
    }

    if (!_canStartUpload(existingState.stage)) {
      return LocalToCloudMigrationUploadResult.blocked(
        LocalToCloudMigrationUploadBlockReason.invalidPreparedState,
        message:
            'Текущий migration state ${existingState.stage.name} не допускает controlled upload.',
      );
    }

    try {
      final ExportBundle bundle = await _prepareExportBundleUseCase();
      const ExportBundleIntegrityService integrityService =
          ExportBundleIntegrityService();
      integrityService.verify(bundle);

      final Map<String, Map<String, Object>> entitiesByFamily =
          _buildBundleEntityMaps(bundle);
      final Map<String, List<LocalToCloudMigrationPlanRow>> planRowsByFamily =
          _groupPlanRowsByFamily(existingState.plan.rows);
      final String? mismatch = _firstPlanMismatch(
        state: existingState,
        entitiesByFamily: entitiesByFamily,
        planRowsByFamily: planRowsByFamily,
      );
      if (mismatch != null) {
        return LocalToCloudMigrationUploadResult.blocked(
          LocalToCloudMigrationUploadBlockReason.planMismatch,
          message: mismatch,
        );
      }

      final Map<String, int> progress = <String, int>{
        ...existingState.uploadedRowCountsByFamily,
      };
      await _firestore.doc('users/$uid/migration_state/status').set(
        <String, dynamic>{
          'migrationId': existingState.plan.migrationId,
          'uid': uid,
          'startedAt': Timestamp.fromDate(existingState.plan.createdAt.toUtc()),
          'stage': 'uploadInProgress',
          'localFingerprint': existingState.plan.localFingerprint,
        },
        SetOptions(merge: true),
      );

      await _migrationStateRepository.saveState(
        _copyState(
          existingState,
          stage: LocalToCloudMigrationStage.uploadInProgress,
          uploadedRowCountsByFamily: progress,
        ),
      );

      for (final String familyKey in uploadOrder) {
        final List<LocalToCloudMigrationPlanRow> familyRows =
            planRowsByFamily[familyKey] ??
            const <LocalToCloudMigrationPlanRow>[];
        if (familyRows.isEmpty) {
          continue;
        }
        final LocalToCloudMigrationEntityUploader uploader =
            _uploaders[familyKey]!;
        final Map<String, Object> familyEntities = entitiesByFamily[familyKey]!;
        int uploadedCount = progress[familyKey] ?? 0;
        for (int index = uploadedCount; index < familyRows.length; index += 1) {
          final LocalToCloudMigrationPlanRow row = familyRows[index];
          final Object entity = familyEntities[row.localRowId]!;
          await uploader(uid, entity);
          uploadedCount = index + 1;
          progress[familyKey] = uploadedCount;
          await _migrationStateRepository.saveState(
            _copyState(
              existingState,
              stage: LocalToCloudMigrationStage.uploadInProgress,
              uploadedRowCountsByFamily: progress,
            ),
          );
        }
      }

      await _firestore.doc('users/$uid/migration_state/status').set(
        <String, dynamic>{'stage': 'uploadCompleted'},
        SetOptions(merge: true),
      );

      await _migrationStateRepository.saveState(
        _copyState(
          existingState,
          stage: LocalToCloudMigrationStage.uploadCompleted,
          uploadedRowCountsByFamily: progress,
        ),
      );
      return LocalToCloudMigrationUploadResult.succeeded(
        uploadedRowCountsByFamily: progress,
        message:
            'Controlled upload completed. Remote verification and local ownership conversion are still required.',
      );
    } catch (error) {
      _logger.logError(
        'Local-to-cloud controlled upload failed for $uid: $error',
        error,
      );
      final LocalToCloudMigrationState? latestState =
          await _migrationStateRepository.getStateForUid(uid);
      final Map<String, int> progress =
          latestState?.uploadedRowCountsByFamily ?? const <String, int>{};
      if (latestState != null && progress.isNotEmpty) {
        await _migrationStateRepository.saveState(
          _copyState(
            latestState,
            stage: LocalToCloudMigrationStage.uploadPartiallyCompleted,
            uploadedRowCountsByFamily: progress,
          ),
        );
      }
      return LocalToCloudMigrationUploadResult.failed(
        message: error.toString(),
        uploadedRowCountsByFamily: progress,
      );
    }
  }

  bool _canStartUpload(LocalToCloudMigrationStage stage) {
    return stage == LocalToCloudMigrationStage.backupCreated ||
        stage == LocalToCloudMigrationStage.uploadInProgress ||
        stage == LocalToCloudMigrationStage.uploadPartiallyCompleted;
  }

  Map<String, List<LocalToCloudMigrationPlanRow>> _groupPlanRowsByFamily(
    List<LocalToCloudMigrationPlanRow> rows,
  ) {
    final Map<String, List<LocalToCloudMigrationPlanRow>> result =
        <String, List<LocalToCloudMigrationPlanRow>>{};
    for (final LocalToCloudMigrationPlanRow row in rows) {
      result
          .putIfAbsent(row.familyKey, () => <LocalToCloudMigrationPlanRow>[])
          .add(row);
    }
    return result;
  }

  String? _firstPlanMismatch({
    required LocalToCloudMigrationState state,
    required Map<String, Map<String, Object>> entitiesByFamily,
    required Map<String, List<LocalToCloudMigrationPlanRow>> planRowsByFamily,
  }) {
    for (final String familyKey in uploadOrder) {
      final List<LocalToCloudMigrationPlanRow> planRows =
          planRowsByFamily[familyKey] ?? const <LocalToCloudMigrationPlanRow>[];
      if (planRows.isEmpty) {
        continue;
      }
      final Map<String, Object>? entities = entitiesByFamily[familyKey];
      if (entities == null) {
        return 'Export bundle does not expose family $familyKey required by the migration plan.';
      }
      for (final LocalToCloudMigrationPlanRow row in planRows) {
        final Object? entity = entities[row.localRowId];
        if (entity == null) {
          return 'Export bundle is missing $familyKey row ${row.localRowId} required by the migration plan.';
        }
        final String expectedDocumentId = _expectedDocumentId(
          familyKey: familyKey,
          entity: entity,
        );
        if (expectedDocumentId != row.documentId) {
          return 'Migration plan document ID mismatch for $familyKey/${row.localRowId}: expected $expectedDocumentId, persisted ${row.documentId}.';
        }
      }
    }
    if (state.localFingerprintBeforeUpload != null &&
        state.localFingerprintBeforeUpload != state.plan.localFingerprint) {
      return 'Persisted migration state has diverged local fingerprints before upload.';
    }
    return null;
  }

  Map<String, Map<String, Object>> _buildBundleEntityMaps(ExportBundle bundle) {
    return <String, Map<String, Object>>{
      'accounts': <String, Object>{
        for (final Object account in bundle.accounts)
          (account as dynamic).id as String: account,
      },
      'categories': <String, Object>{
        for (final Object category in bundle.categories)
          (category as dynamic).id as String: category,
      },
      'tags': <String, Object>{
        for (final Object tag in bundle.tags)
          (tag as dynamic).id as String: tag,
      },
      'transactions': <String, Object>{
        for (final Object tx in bundle.transactions)
          (tx as dynamic).id as String: tx,
      },
      'transaction_tags': <String, Object>{
        for (final TransactionTagEntity link in bundle.transactionTags)
          _transactionTagRowId(link): link,
      },
      'budgets': <String, Object>{
        for (final Object budget in bundle.budgets)
          (budget as dynamic).id as String: budget,
      },
      'budget_instances': <String, Object>{
        for (final Object budgetInstance in bundle.budgetInstances)
          (budgetInstance as dynamic).id as String: budgetInstance,
      },
      'saving_goals': <String, Object>{
        for (final Object goal in bundle.savingGoals)
          (goal as dynamic).id as String: goal,
      },
      'credits': <String, Object>{
        for (final Object credit in bundle.credits)
          (credit as dynamic).id as String: credit,
      },
      'credit_cards': <String, Object>{
        for (final Object card in bundle.creditCards)
          (card as dynamic).id as String: card,
      },
      'debts': <String, Object>{
        for (final Object debt in bundle.debts)
          (debt as dynamic).id as String: debt,
      },
      'credit_payment_schedules': <String, Object>{
        for (final Object schedule in bundle.creditPaymentSchedules)
          (schedule as dynamic).id as String: schedule,
      },
      'credit_payment_groups': <String, Object>{
        for (final Object group in bundle.creditPaymentGroups)
          (group as dynamic).id as String: group,
      },
      'upcoming_payments': <String, Object>{
        for (final Object payment in bundle.upcomingPayments)
          (payment as dynamic).id as String: payment,
      },
      'payment_reminders': <String, Object>{
        for (final Object reminder in bundle.paymentReminders)
          (reminder as dynamic).id as String: reminder,
      },
    };
  }

  String _expectedDocumentId({
    required String familyKey,
    required Object entity,
  }) {
    return switch (familyKey) {
      'transaction_tags' => _transactionTagRowId(
        entity as TransactionTagEntity,
      ),
      _ => (entity as dynamic).id as String,
    };
  }

  String _transactionTagRowId(TransactionTagEntity link) {
    return '${link.transactionId}::${link.tagId}';
  }

  LocalToCloudMigrationState _copyState(
    LocalToCloudMigrationState state, {
    required LocalToCloudMigrationStage stage,
    required Map<String, int> uploadedRowCountsByFamily,
  }) {
    return LocalToCloudMigrationState(
      uid: state.uid,
      stage: stage,
      createdAt: state.createdAt,
      updatedAt: DateTime.now().toUtc(),
      plan: state.plan,
      version: state.version,
      backupArtifactReference: state.backupArtifactReference,
      backupChecksum: state.backupChecksum,
      localFingerprintBeforeUpload: state.localFingerprintBeforeUpload,
      remoteFingerprintBeforeUpload: state.remoteFingerprintBeforeUpload,
      uploadedRowCountsByFamily: Map<String, int>.unmodifiable(
        uploadedRowCountsByFamily,
      ),
    );
  }
}

final Provider<LocalToCloudMigrationUploadService>
localToCloudMigrationUploadServiceProvider =
    Provider<LocalToCloudMigrationUploadService>((Ref ref) {
      return LocalToCloudMigrationUploadService(
        firestore: ref.watch(firestoreProvider),
        migrationStateRepository: ref.watch(
          localToCloudMigrationStateRepositoryProvider,
        ),
        prepareExportBundleUseCase: ref.watch(
          prepareExportBundleUseCaseProvider,
        ),
        logger: ref.watch(loggerServiceProvider),
        uploaders: <String, LocalToCloudMigrationEntityUploader>{
          'accounts': (String uid, Object entity) => ref
              .read(accountRemoteDataSourceProvider)
              .upsert(uid, entity as AccountEntity),
          'categories': (String uid, Object entity) => ref
              .read(categoryRemoteDataSourceProvider)
              .upsert(uid, entity as Category),
          'tags': (String uid, Object entity) => ref
              .read(tagRemoteDataSourceProvider)
              .upsert(uid, entity as TagEntity),
          'transactions': (String uid, Object entity) => ref
              .read(transactionRemoteDataSourceProvider)
              .upsert(uid, entity as TransactionEntity),
          'transaction_tags': (String uid, Object entity) => ref
              .read(transactionTagRemoteDataSourceProvider)
              .upsert(uid, entity as TransactionTagEntity),
          'budgets': (String uid, Object entity) => ref
              .read(budgetRemoteDataSourceProvider)
              .upsert(uid, entity as Budget),
          'budget_instances': (String uid, Object entity) => ref
              .read(budgetInstanceRemoteDataSourceProvider)
              .upsert(uid, entity as BudgetInstance),
          'saving_goals': (String uid, Object entity) => ref
              .read(savingGoalRemoteDataSourceProvider)
              .upsert(uid, entity as SavingGoal),
          'credits': (String uid, Object entity) => ref
              .read(creditRemoteDataSourceProvider)
              .upsert(uid, entity as CreditEntity),
          'credit_cards': (String uid, Object entity) => ref
              .read(creditCardRemoteDataSourceProvider)
              .upsert(uid, entity as CreditCardEntity),
          'debts': (String uid, Object entity) => ref
              .read(debtRemoteDataSourceProvider)
              .upsert(uid, entity as DebtEntity),
          'credit_payment_schedules': (String uid, Object entity) => ref
              .read(creditPaymentScheduleRemoteDataSourceProvider)
              .upsert(uid, entity as CreditPaymentScheduleEntity),
          'credit_payment_groups': (String uid, Object entity) => ref
              .read(creditPaymentGroupRemoteDataSourceProvider)
              .upsert(uid, entity as CreditPaymentGroupEntity),
          'upcoming_payments': (String uid, Object entity) => ref
              .read(upcomingPaymentRemoteDataSourceProvider)
              .upsert(uid, entity as UpcomingPayment),
          'payment_reminders': (String uid, Object entity) => ref
              .read(paymentReminderRemoteDataSourceProvider)
              .upsert(uid, entity as PaymentReminder),
        },
      );
    });
