import 'dart:convert';

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
import 'package:kopim/core/services/sync/sync_contract.dart';
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

typedef LocalToCloudMigrationRemoteCollectionReader =
    Future<Map<String, Map<String, dynamic>>> Function(String uid);
typedef LocalToCloudMigrationExpectedRemotePayloadBuilder =
    Map<String, dynamic> Function(Object entity);

enum LocalToCloudMigrationRemoteVerificationStatus {
  succeeded,
  blocked,
  failed,
}

enum LocalToCloudMigrationRemoteVerificationBlockReason {
  missingPreparedState,
  invalidPreparedState,
  planMismatch,
  remoteDataMismatch,
}

class LocalToCloudMigrationRemoteVerificationResult {
  const LocalToCloudMigrationRemoteVerificationResult._({
    required this.status,
    this.blockReason,
    this.message,
    this.verifiedRowCountsByFamily = const <String, int>{},
  });

  const LocalToCloudMigrationRemoteVerificationResult.succeeded({
    required Map<String, int> verifiedRowCountsByFamily,
    String? message,
  }) : this._(
         status: LocalToCloudMigrationRemoteVerificationStatus.succeeded,
         message: message,
         verifiedRowCountsByFamily: verifiedRowCountsByFamily,
       );

  const LocalToCloudMigrationRemoteVerificationResult.blocked(
    LocalToCloudMigrationRemoteVerificationBlockReason reason, {
    String? message,
  }) : this._(
         status: LocalToCloudMigrationRemoteVerificationStatus.blocked,
         blockReason: reason,
         message: message,
       );

  const LocalToCloudMigrationRemoteVerificationResult.failed({
    String? message,
    Map<String, int> verifiedRowCountsByFamily = const <String, int>{},
  }) : this._(
         status: LocalToCloudMigrationRemoteVerificationStatus.failed,
         message: message,
         verifiedRowCountsByFamily: verifiedRowCountsByFamily,
       );

  final LocalToCloudMigrationRemoteVerificationStatus status;
  final LocalToCloudMigrationRemoteVerificationBlockReason? blockReason;
  final String? message;
  final Map<String, int> verifiedRowCountsByFamily;
}

class LocalToCloudMigrationRemoteVerificationService {
  LocalToCloudMigrationRemoteVerificationService({
    required LocalToCloudMigrationStateRepository migrationStateRepository,
    required PrepareExportBundleUseCase prepareExportBundleUseCase,
    required Map<String, LocalToCloudMigrationRemoteCollectionReader> readers,
    required Map<String, LocalToCloudMigrationExpectedRemotePayloadBuilder>
    expectedPayloadBuilders,
    required LoggerService logger,
  }) : _migrationStateRepository = migrationStateRepository,
       _prepareExportBundleUseCase = prepareExportBundleUseCase,
       _readers =
           Map<
             String,
             LocalToCloudMigrationRemoteCollectionReader
           >.unmodifiable(readers),
       _expectedPayloadBuilders =
           Map<
             String,
             LocalToCloudMigrationExpectedRemotePayloadBuilder
           >.unmodifiable(expectedPayloadBuilders),
       _logger = logger;

  final LocalToCloudMigrationStateRepository _migrationStateRepository;
  final PrepareExportBundleUseCase _prepareExportBundleUseCase;
  final Map<String, LocalToCloudMigrationRemoteCollectionReader> _readers;
  final Map<String, LocalToCloudMigrationExpectedRemotePayloadBuilder>
  _expectedPayloadBuilders;
  final LoggerService _logger;

  Future<LocalToCloudMigrationRemoteVerificationResult> verifyUploadedGraph({
    required String uid,
  }) async {
    final LocalToCloudMigrationState? existingState =
        await _migrationStateRepository.getStateForUid(uid);
    if (existingState == null) {
      return const LocalToCloudMigrationRemoteVerificationResult.blocked(
        LocalToCloudMigrationRemoteVerificationBlockReason.missingPreparedState,
        message: 'Для remote verification нет подготовленного durable state.',
      );
    }

    if (!_canStartVerification(existingState.stage)) {
      return LocalToCloudMigrationRemoteVerificationResult.blocked(
        LocalToCloudMigrationRemoteVerificationBlockReason.invalidPreparedState,
        message:
            'Текущий migration state ${existingState.stage.name} не допускает remote verification.',
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
        return LocalToCloudMigrationRemoteVerificationResult.blocked(
          LocalToCloudMigrationRemoteVerificationBlockReason.planMismatch,
          message: mismatch,
        );
      }

      final Map<String, int> verifiedCounts = <String, int>{
        ...existingState.verifiedRowCountsByFamily,
      };
      await _migrationStateRepository.saveState(
        _copyState(
          existingState,
          stage: LocalToCloudMigrationStage.remoteVerificationInProgress,
          verifiedRowCountsByFamily: verifiedCounts,
        ),
      );

      for (final MapEntry<String, List<LocalToCloudMigrationPlanRow>> entry
          in planRowsByFamily.entries) {
        final String familyKey = entry.key;
        final List<LocalToCloudMigrationPlanRow> familyRows = entry.value;
        if (familyRows.isEmpty) {
          continue;
        }

        final LocalToCloudMigrationRemoteCollectionReader? reader =
            _readers[familyKey];
        final LocalToCloudMigrationExpectedRemotePayloadBuilder?
        expectedPayloadBuilder = _expectedPayloadBuilders[familyKey];
        if (reader == null || expectedPayloadBuilder == null) {
          return LocalToCloudMigrationRemoteVerificationResult.blocked(
            LocalToCloudMigrationRemoteVerificationBlockReason
                .invalidPreparedState,
            message:
                'Remote verification is not configured for family $familyKey.',
          );
        }

        final Map<String, Map<String, dynamic>> remoteDocuments = await reader(
          uid,
        );
        final Set<String> expectedDocumentIds = familyRows
            .map((LocalToCloudMigrationPlanRow row) => row.documentId)
            .toSet();
        final Set<String> actualDocumentIds = remoteDocuments.keys.toSet();
        final Set<String> extraDocumentIds = actualDocumentIds.difference(
          expectedDocumentIds,
        );
        if (extraDocumentIds.isNotEmpty) {
          return LocalToCloudMigrationRemoteVerificationResult.blocked(
            LocalToCloudMigrationRemoteVerificationBlockReason
                .remoteDataMismatch,
            message:
                'Remote verification found unexpected $familyKey documents: ${extraDocumentIds.toList()..sort()}.',
          );
        }

        final Set<String> missingDocumentIds = expectedDocumentIds.difference(
          actualDocumentIds,
        );
        if (missingDocumentIds.isNotEmpty) {
          return LocalToCloudMigrationRemoteVerificationResult.blocked(
            LocalToCloudMigrationRemoteVerificationBlockReason
                .remoteDataMismatch,
            message:
                'Remote verification is missing $familyKey documents: ${missingDocumentIds.toList()..sort()}.',
          );
        }

        for (final LocalToCloudMigrationPlanRow row in familyRows) {
          final Object entity = entitiesByFamily[familyKey]![row.localRowId]!;
          final Object? actualPayload = remoteDocuments[row.documentId];
          final Object expectedPayload = expectedPayloadBuilder(entity);
          final Object? canonicalActual = _canonicalize(actualPayload);
          final Object? canonicalExpected = _canonicalize(expectedPayload);
          if (jsonEncode(canonicalActual) != jsonEncode(canonicalExpected)) {
            return LocalToCloudMigrationRemoteVerificationResult.blocked(
              LocalToCloudMigrationRemoteVerificationBlockReason
                  .remoteDataMismatch,
              message:
                  'Remote payload mismatch for $familyKey/${row.documentId}.',
            );
          }
        }

        verifiedCounts[familyKey] = familyRows.length;
        await _migrationStateRepository.saveState(
          _copyState(
            existingState,
            stage: LocalToCloudMigrationStage.remoteVerificationInProgress,
            verifiedRowCountsByFamily: verifiedCounts,
          ),
        );
      }

      await _migrationStateRepository.saveState(
        _copyState(
          existingState,
          stage: LocalToCloudMigrationStage.remoteVerified,
          verifiedRowCountsByFamily: verifiedCounts,
        ),
      );
      return LocalToCloudMigrationRemoteVerificationResult.succeeded(
        verifiedRowCountsByFamily: verifiedCounts,
        message:
            'Uploaded remote graph matches the deterministic migration plan and canonical payloads.',
      );
    } catch (error) {
      _logger.logError(
        'Local-to-cloud remote verification failed for $uid: $error',
        error,
      );
      final LocalToCloudMigrationState? latestState =
          await _migrationStateRepository.getStateForUid(uid);
      return LocalToCloudMigrationRemoteVerificationResult.failed(
        message: error.toString(),
        verifiedRowCountsByFamily:
            latestState?.verifiedRowCountsByFamily ?? const <String, int>{},
      );
    }
  }

  bool _canStartVerification(LocalToCloudMigrationStage stage) {
    return stage == LocalToCloudMigrationStage.uploadCompleted ||
        stage == LocalToCloudMigrationStage.remoteVerificationInProgress ||
        stage == LocalToCloudMigrationStage.remoteVerified;
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
    for (final MapEntry<String, List<LocalToCloudMigrationPlanRow>> entry
        in planRowsByFamily.entries) {
      final String familyKey = entry.key;
      final List<LocalToCloudMigrationPlanRow> planRows = entry.value;
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
      return 'Persisted migration state has diverged local fingerprints before verification.';
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

  Object? _canonicalize(Object? value) {
    if (value is double) return value;
    if (value is int) return value;
    if (value is Timestamp) {
      return value.toDate().toUtc().toIso8601String();
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is Map<Object?, Object?>) {
      final List<String> keys = value.keys.map((Object? key) => '$key').toList()
        ..sort();
      final Map<String, Object?> result = <String, Object?>{
        for (final String key in keys) key: _canonicalize(value[key]),
      };
      result.removeWhere(
        (String _, Object? nestedValue) => nestedValue == null,
      );
      return result;
    }
    if (value is Iterable<Object?>) {
      return value.map(_canonicalize).toList(growable: false);
    }
    return value;
  }

  LocalToCloudMigrationState _copyState(
    LocalToCloudMigrationState state, {
    required LocalToCloudMigrationStage stage,
    required Map<String, int> verifiedRowCountsByFamily,
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
      uploadedRowCountsByFamily: state.uploadedRowCountsByFamily,
      verifiedRowCountsByFamily: Map<String, int>.unmodifiable(
        verifiedRowCountsByFamily,
      ),
    );
  }
}

final Provider<LocalToCloudMigrationRemoteVerificationService>
localToCloudMigrationRemoteVerificationServiceProvider =
    Provider<LocalToCloudMigrationRemoteVerificationService>((Ref ref) {
      return LocalToCloudMigrationRemoteVerificationService(
        migrationStateRepository: ref.watch(
          localToCloudMigrationStateRepositoryProvider,
        ),
        prepareExportBundleUseCase: ref.watch(
          prepareExportBundleUseCaseProvider,
        ),
        logger: ref.watch(loggerServiceProvider),
        readers: <String, LocalToCloudMigrationRemoteCollectionReader>{
          'accounts': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.accountsCollection,
          ),
          'categories': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.categoriesCollection,
          ),
          'tags': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.tagsCollection,
          ),
          'transactions': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.transactionsCollection,
          ),
          'transaction_tags': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.transactionTagsCollection,
          ),
          'budgets': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.budgetsCollection,
          ),
          'budget_instances': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.budgetInstancesCollection,
          ),
          'saving_goals': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.savingGoalsCollection,
          ),
          'credits': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.creditsCollection,
          ),
          'credit_cards': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.creditCardsCollection,
          ),
          'debts': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.debtsCollection,
          ),
          'credit_payment_schedules': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.creditPaymentSchedulesCollection,
          ),
          'credit_payment_groups': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.creditPaymentGroupsCollection,
          ),
          'upcoming_payments': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.upcomingPaymentsCollection,
          ),
          'payment_reminders': _makeReader(
            ref.watch(firestoreProvider),
            SyncContract.paymentRemindersCollection,
          ),
        },
        expectedPayloadBuilders:
            <String, LocalToCloudMigrationExpectedRemotePayloadBuilder>{
              'accounts': (Object entity) => ref
                  .read(accountRemoteDataSourceProvider)
                  .toFirestorePayload(entity as AccountEntity),
              'categories': (Object entity) => ref
                  .read(categoryRemoteDataSourceProvider)
                  .toFirestorePayload(entity as Category),
              'tags': (Object entity) => ref
                  .read(tagRemoteDataSourceProvider)
                  .toFirestorePayload(entity as TagEntity),
              'transactions': (Object entity) => ref
                  .read(transactionRemoteDataSourceProvider)
                  .toFirestorePayload(entity as TransactionEntity),
              'transaction_tags': (Object entity) => ref
                  .read(transactionTagRemoteDataSourceProvider)
                  .toFirestorePayload(entity as TransactionTagEntity),
              'budgets': (Object entity) => ref
                  .read(budgetRemoteDataSourceProvider)
                  .toFirestorePayload(entity as Budget),
              'budget_instances': (Object entity) => ref
                  .read(budgetInstanceRemoteDataSourceProvider)
                  .toFirestorePayload(entity as BudgetInstance),
              'saving_goals': (Object entity) => ref
                  .read(savingGoalRemoteDataSourceProvider)
                  .toFirestorePayload(entity as SavingGoal),
              'credits': (Object entity) => ref
                  .read(creditRemoteDataSourceProvider)
                  .toFirestorePayload(entity as CreditEntity),
              'credit_cards': (Object entity) => ref
                  .read(creditCardRemoteDataSourceProvider)
                  .toFirestorePayload(entity as CreditCardEntity),
              'debts': (Object entity) => ref
                  .read(debtRemoteDataSourceProvider)
                  .toFirestorePayload(entity as DebtEntity),
              'credit_payment_schedules': (Object entity) => ref
                  .read(creditPaymentScheduleRemoteDataSourceProvider)
                  .toFirestorePayload(entity as CreditPaymentScheduleEntity),
              'credit_payment_groups': (Object entity) => ref
                  .read(creditPaymentGroupRemoteDataSourceProvider)
                  .toFirestorePayload(entity as CreditPaymentGroupEntity),
              'upcoming_payments': (Object entity) => ref
                  .read(upcomingPaymentRemoteDataSourceProvider)
                  .toFirestorePayload(entity as UpcomingPayment),
              'payment_reminders': (Object entity) => ref
                  .read(paymentReminderRemoteDataSourceProvider)
                  .toFirestorePayload(entity as PaymentReminder),
            },
      );
    });

LocalToCloudMigrationRemoteCollectionReader _makeReader(
  FirebaseFirestore firestore,
  String collectionName,
) {
  return (String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection(collectionName)
        .get();
    return <String, Map<String, dynamic>>{
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs)
        doc.id: doc.data(),
    };
  };
}
