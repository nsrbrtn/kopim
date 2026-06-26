import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';

import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/cloud_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_readiness_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_execution_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_runtime_guard.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_upload_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_remote_verification_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_local_ownership_conversion_service.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/cloud_activation_state.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';
import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_account_cleanup_repository.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_integrity_service.dart';
import 'package:kopim/features/settings/domain/use_cases/export_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/profile/application/migration_write_guard.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_snapshot_builder.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/domain/entities/migration_freeze_state.dart';
import 'package:kopim/features/profile/data/migration_freeze_state_repository.dart';

class _FakeLoggerService extends LoggerService {
  @override
  void logInfo(String message) {}
  @override
  void logWarning(String message) {}
  @override
  void logError(String message, [dynamic error]) {}
}

class _FakeCloudEntitlementRepository implements CloudEntitlementRepository {
  _FakeCloudEntitlementRepository(this.state);
  final CloudEntitlementState state;

  @override
  Future<CloudEntitlementState> getCachedState() async => state;
  Future<CloudEntitlementState> refreshState() async => state;
  @override
  Future<CloudEntitlementResult> activateKey(String key) async =>
      CloudEntitlementResult(success: true, state: state);
  @override
  Future<void> clearEntitlement() async {}
}

class _FakeCloudActivationStateRepository
    implements CloudActivationStateRepository {
  CloudActivationState? state;

  @override
  Future<CloudActivationState?> getStateForUid(String uid) async {
    if (state?.uid == uid) return state;
    return null;
  }

  @override
  Future<void> saveEnabledState({
    required String uid,
    required String scenario,
    required String? localFingerprint,
    required String? remoteFingerprint,
  }) async {
    state = CloudActivationState(
      uid: uid,
      scenario: scenario,
      activatedAt: DateTime.now().toUtc(),
      localFingerprint: localFingerprint,
      remoteFingerprint: remoteFingerprint,
      version: 1,
    );
  }

  @override
  Future<void> clearStateForUid(String uid) async {
    if (state?.uid == uid) {
      state = null;
    }
  }
}

class _FakeMigrationStateRepository
    implements LocalToCloudMigrationStateRepository {
  _FakeMigrationStateRepository(this.state);
  LocalToCloudMigrationState? state;

  @override
  Future<void> clearStateForUid(String uid) async {
    state = null;
  }

  @override
  Future<LocalToCloudMigrationState?> getStateForUid(String uid) async {
    return state;
  }

  @override
  Future<void> saveState(LocalToCloudMigrationState state) async {
    this.state = state;
  }
}

class _FakePrepareExportBundleUseCase implements PrepareExportBundleUseCase {
  _FakePrepareExportBundleUseCase(this.bundle);
  final ExportBundle bundle;

  @override
  Future<ExportBundle> call() async => bundle;
}

class _FakeExportUserDataUseCase implements ExportUserDataUseCase {
  _FakeExportUserDataUseCase(this.result);
  final ExportFileSaveResult result;

  @override
  Future<ExportFileSaveResult> call(ExportUserDataParams params) async =>
      result;
}

class _FakeUserAccountCleanupRepository
    implements UserAccountCleanupRepository {
  @override
  Future<void> deleteLocalUserData(String uid) async {}
  @override
  Future<void> deleteRemoteUserData(String uid) async {}
}

class _FakeLocalToCloudMigrationReadinessService
    implements LocalToCloudMigrationReadinessService {
  _FakeLocalToCloudMigrationReadinessService(this.result);
  final LocalToCloudMigrationPreflightResult result;

  @override
  Future<LocalToCloudMigrationPreflightResult> captureReadiness({
    String? uid,
  }) async => result;
}

class _FakeMigrationFreezeStateRepository
    implements MigrationFreezeStateRepository {
  MigrationFreezeState? state;

  @override
  Future<MigrationFreezeState?> getState() async => state;

  @override
  Future<void> saveState(MigrationFreezeState state) async {
    this.state = state;
  }

  @override
  Future<void> clearState() async {
    state = null;
  }
}

void main() {
  group('Local-to-Cloud Migration Integration Tests', () {
    late db.AppDatabase database;
    late OutboxDao outboxDao;
    late FakeFirebaseFirestore firestore;
    late _FakeCloudActivationStateRepository activationStateRepo;
    late _FakeMigrationStateRepository migrationStateRepo;
    late String? currentUid;

    const AuthUser testUser = AuthUser(
      uid: 'user-123',
      email: 'test@example.com',
      isAnonymous: false,
    );

    const CloudActivationIntentState intentState = CloudActivationIntentState(
      stage: CloudActivationIntentStage.pendingChoice,
      pendingChoice: CloudActivationChoice.migrateLocalToCloud,
      scenario: CloudActivationScenario.localHasDataRemoteEmpty,
      localSnapshotState: CloudActivationSnapshotState.hasData,
      remoteSnapshotState: CloudActivationSnapshotState.empty,
      localFingerprint: null,
      remoteFingerprint: null,
    );

    const DataModeState currentMode = DataModeState(
      dataMode: DataMode.localOnly,
      entitlementState: CloudEntitlementState.active,
      migrationDecision: MigrationDecision.none,
    );

    setUp(() async {
      currentUid = null;
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
      database = db.AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );
      outboxDao = OutboxDao(database, () => currentUid);
      firestore = FakeFirebaseFirestore();
      activationStateRepo = _FakeCloudActivationStateRepository();
      migrationStateRepo = _FakeMigrationStateRepository(null);
    });

    tearDown(() async {
      await database.close();
    });

    ExportBundle buildBundle({
      required List<AccountEntity> accounts,
      required List<TransactionEntity> transactions,
    }) {
      final ExportBundle base = ExportBundle(
        schemaVersion: '2026-01',
        generatedAt: DateTime.utc(2024, 1, 1),
        accounts: accounts,
        transactions: transactions,
      );
      const ExportBundleIntegrityService integrityService =
          ExportBundleIntegrityService();
      return base.copyWith(integrity: integrityService.buildIntegrity(base));
    }

    test(
      'Success Path: runs all stages sequentially and transitions to cloudEnabled',
      () async {
        // 1. Populate local DB & outbox
        final DateTime now = DateTime.utc(2024, 1, 1);
        final AccountEntity localAccount = AccountEntity(
          id: 'acc-1',
          name: 'Cash',
          balanceMinor: BigInt.zero,
          openingBalanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'cash',
          createdAt: now,
          updatedAt: now,
        );

        // Insert account record locally
        await database
            .into(database.accounts)
            .insert(
              db.AccountsCompanion.insert(
                id: 'acc-1',
                name: 'Cash',
                balance: 0,
                currency: 'RUB',
                type: 'cash',
                createdAt: Value<DateTime>(now),
                updatedAt: Value<DateTime>(now),
              ),
            );

        // Enqueue to outbox
        await outboxDao.enqueue(
          entityType: 'account',
          entityId: 'acc-1',
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{'id': 'acc-1', 'name': 'Cash'},
        );

        final ExportBundle bundle = buildBundle(
          accounts: <AccountEntity>[localAccount],
          transactions: const <TransactionEntity>[],
        );

        const LocalToCloudMigrationPreflightResult preflightResult =
            LocalToCloudMigrationPreflightResult.ready(
              localSummary: LocalSnapshotSummary(
                state: LocalSnapshotState.hasPendingOutbox,
                hasUserData: true,
                hasSystemData: false,
                pendingOutboxCount: 1,
                fingerprint:
                    'local:hasPendingOutbox|user:true|system:false|outbox:1',
              ),
              inventorySnapshot: LocalToCloudMigrationInventorySnapshot(
                candidateFamilyKeys: <String>{'accounts'},
                rowsByFamily: <String, List<LocalToCloudMigrationRow>>{
                  'accounts': <LocalToCloudMigrationRow>[
                    LocalToCloudMigrationRow(
                      familyKey: 'accounts',
                      localRowId: 'acc-1',
                      reusedDocumentId: 'acc-1',
                    ),
                  ],
                },
              ),
              readinessResult: LocalToCloudMigrationReadinessResult(
                status: LocalToCloudMigrationReadinessStatus.ready,
                issues: <LocalToCloudMigrationReadinessIssue>[],
              ),
            );

        final LocalSnapshotSummaryService localSummaryService =
            LocalSnapshotSummaryService(
              database: database,
              outboxDao: outboxDao,
              activationRuntimeGuard: CloudActivationRuntimeGuard(),
            );

        final CloudSnapshotSummaryService cloudSummaryService =
            CloudSnapshotSummaryService(firestore: firestore);

        // Setup execution service
        final LocalToCloudMigrationUploadService uploadService =
            LocalToCloudMigrationUploadService(
              firestore: firestore,
              migrationStateRepository: migrationStateRepo,
              prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
                bundle,
              ),
              uploaders: <String, LocalToCloudMigrationEntityUploader>{
                'accounts': (String uid, Object entity) async {
                  final AccountEntity acc = entity as AccountEntity;
                  await firestore
                      .collection('users')
                      .doc(uid)
                      .collection('accounts')
                      .doc(acc.id)
                      .set(<String, dynamic>{
                        'id': acc.id,
                        'name': acc.name,
                        'balance': 0.0,
                        'balanceMinor': '0',
                      });
                },
              },
              logger: _FakeLoggerService(),
            );

        final LocalToCloudMigrationRemoteVerificationService
        verificationService = LocalToCloudMigrationRemoteVerificationService(
          migrationStateRepository: migrationStateRepo,
          prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(bundle),
          readers: <String, LocalToCloudMigrationRemoteCollectionReader>{
            'accounts': (String uid) async {
              final QuerySnapshot<Map<String, dynamic>> snap = await firestore
                  .collection('users')
                  .doc(uid)
                  .collection('accounts')
                  .get();
              return <String, Map<String, dynamic>>{
                for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                    in snap.docs)
                  doc.id: doc.data(),
              };
            },
          },
          expectedPayloadBuilders:
              <String, LocalToCloudMigrationExpectedRemotePayloadBuilder>{
                'accounts': (Object entity) {
                  final AccountEntity acc = entity as AccountEntity;
                  return <String, dynamic>{
                    'id': acc.id,
                    'name': acc.name,
                    'balance': 0.0,
                    'balanceMinor': '0',
                  };
                },
              },
          logger: _FakeLoggerService(),
        );

        final LocalToCloudMigrationLocalOwnershipConversionService
        conversionService =
            LocalToCloudMigrationLocalOwnershipConversionService(
              database: database,
              outboxDao: outboxDao,
              migrationStateRepository: migrationStateRepo,
              logger: _FakeLoggerService(),
            );

        final CloudActivationExecutionService executionService =
            CloudActivationExecutionService(
              firestore: firestore,
              uploadService: uploadService,
              remoteVerificationService: verificationService,
              localOwnershipConversionService: conversionService,
              activationStateRepository: activationStateRepo,
              migrationStateRepository: migrationStateRepo,
              entitlementRepository: _FakeCloudEntitlementRepository(
                CloudEntitlementState.active,
              ),
              localSnapshotSummaryService: localSummaryService,
              cloudSnapshotSummaryService: cloudSummaryService,
              localToCloudMigrationReadinessService:
                  _FakeLocalToCloudMigrationReadinessService(preflightResult),
              prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
                bundle,
              ),
              exportUserDataUseCase: _FakeExportUserDataUseCase(
                ExportFileSaveResult.success(filePath: '/tmp/test-backup.json'),
              ),
              userAccountCleanupRepository: _FakeUserAccountCleanupRepository(),
              runtimeGuard: CloudActivationRuntimeGuard(),
              logger: _FakeLoggerService(),
            );

        // Run preflight
        final CloudActivationExecutionResult preflightRes =
            await executionService.confirmMigrateLocalToCloudPreflight(
              currentUser: testUser,
              intentState: intentState,
              currentMode: currentMode,
            );
        expect(preflightRes.status, CloudActivationExecutionStatus.succeeded);
        expect(
          migrationStateRepo.state!.stage,
          LocalToCloudMigrationStage.backupCreated,
        );

        // Run execution
        DataModeState simulatedMode = currentMode;
        final CloudActivationExecutionResult execRes = await executionService
            .confirmMigrateLocalToCloudExecution(
              currentUser: testUser,
              intentState: intentState,
              currentMode: simulatedMode,
              refreshRuntimeMode: () async {
                currentUid = testUser.uid;
                simulatedMode = const DataModeState(
                  dataMode: DataMode.cloudEnabled,
                  entitlementState: CloudEntitlementState.active,
                  migrationDecision: MigrationDecision.none,
                );
                return simulatedMode;
              },
            );
        expect(execRes.status, CloudActivationExecutionStatus.succeeded);
        expect(
          migrationStateRepo.state!.stage,
          LocalToCloudMigrationStage.completed,
        );

        // Verify remote marker stage is completed
        final DocumentSnapshot<Map<String, dynamic>> marker = await firestore
            .doc('users/${testUser.uid}/migration_state/status')
            .get();
        expect(marker.exists, isTrue);
        expect(marker.data()!['stage'], 'completed');

        // Verify local database is converted
        final db.LocalRowOwnershipRow? ownership = await database.getOwnership(
          'account',
          'acc-1',
        );
        expect(ownership, isNotNull);
        expect(ownership!.ownershipState, 'cloudOwned');
        expect(ownership.ownerUid, testUser.uid);

        // Verify outbox entry is consumed
        final List<db.OutboxEntryRow> pendingOutbox = await outboxDao
            .fetchPending();
        expect(pendingOutbox, isEmpty);
      },
    );

    test(
      'Crash Recovery Path: upload fails halfway, saves progress, resumes and completes',
      () async {
        final DateTime now = DateTime.utc(2024, 1, 1);
        final AccountEntity acc1 = AccountEntity(
          id: 'acc-1',
          name: 'Card 1',
          balanceMinor: BigInt.zero,
          openingBalanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'card',
          createdAt: now,
          updatedAt: now,
        );
        final AccountEntity acc2 = AccountEntity(
          id: 'acc-2',
          name: 'Card 2',
          balanceMinor: BigInt.zero,
          openingBalanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'card',
          createdAt: now,
          updatedAt: now,
        );

        await database
            .into(database.accounts)
            .insert(
              db.AccountsCompanion.insert(
                id: 'acc-1',
                name: 'Card 1',
                balance: 0,
                currency: 'RUB',
                type: 'card',
                createdAt: Value<DateTime>(now),
                updatedAt: Value<DateTime>(now),
              ),
            );
        await database
            .into(database.accounts)
            .insert(
              db.AccountsCompanion.insert(
                id: 'acc-2',
                name: 'Card 2',
                balance: 0,
                currency: 'RUB',
                type: 'card',
                createdAt: Value<DateTime>(now),
                updatedAt: Value<DateTime>(now),
              ),
            );

        final ExportBundle bundle = buildBundle(
          accounts: <AccountEntity>[acc1, acc2],
          transactions: const <TransactionEntity>[],
        );

        const LocalToCloudMigrationPreflightResult preflightResult =
            LocalToCloudMigrationPreflightResult.ready(
              localSummary: LocalSnapshotSummary(
                state: LocalSnapshotState.hasUserData,
                hasUserData: true,
                hasSystemData: false,
                pendingOutboxCount: 0,
                fingerprint:
                    'local:hasUserData|user:true|system:false|outbox:0',
              ),
              inventorySnapshot: LocalToCloudMigrationInventorySnapshot(
                candidateFamilyKeys: <String>{'accounts'},
                rowsByFamily: <String, List<LocalToCloudMigrationRow>>{
                  'accounts': <LocalToCloudMigrationRow>[
                    LocalToCloudMigrationRow(
                      familyKey: 'accounts',
                      localRowId: 'acc-1',
                      reusedDocumentId: 'acc-1',
                    ),
                    LocalToCloudMigrationRow(
                      familyKey: 'accounts',
                      localRowId: 'acc-2',
                      reusedDocumentId: 'acc-2',
                    ),
                  ],
                },
              ),
              readinessResult: LocalToCloudMigrationReadinessResult(
                status: LocalToCloudMigrationReadinessStatus.ready,
                issues: <LocalToCloudMigrationReadinessIssue>[],
              ),
            );

        bool throwOnSecond = true;

        final LocalToCloudMigrationUploadService uploadService =
            LocalToCloudMigrationUploadService(
              firestore: firestore,
              migrationStateRepository: migrationStateRepo,
              prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
                bundle,
              ),
              uploaders: <String, LocalToCloudMigrationEntityUploader>{
                'accounts': (String uid, Object entity) async {
                  final AccountEntity acc = entity as AccountEntity;
                  if (acc.id == 'acc-2' && throwOnSecond) {
                    throw FirebaseException(
                      plugin: 'cloud_firestore',
                      code: 'unavailable',
                      message: 'Network is down',
                    );
                  }
                  await firestore
                      .collection('users')
                      .doc(uid)
                      .collection('accounts')
                      .doc(acc.id)
                      .set(<String, dynamic>{
                        'id': acc.id,
                        'name': acc.name,
                        'balance': 0.0,
                        'balanceMinor': '0',
                      });
                },
              },
              logger: _FakeLoggerService(),
            );

        final LocalToCloudMigrationRemoteVerificationService
        verificationService = LocalToCloudMigrationRemoteVerificationService(
          migrationStateRepository: migrationStateRepo,
          prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(bundle),
          readers: <String, LocalToCloudMigrationRemoteCollectionReader>{
            'accounts': (String uid) async {
              final QuerySnapshot<Map<String, dynamic>> snap = await firestore
                  .collection('users')
                  .doc(uid)
                  .collection('accounts')
                  .get();
              return <String, Map<String, dynamic>>{
                for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                    in snap.docs)
                  doc.id: doc.data(),
              };
            },
          },
          expectedPayloadBuilders:
              <String, LocalToCloudMigrationExpectedRemotePayloadBuilder>{
                'accounts': (Object entity) {
                  final AccountEntity acc = entity as AccountEntity;
                  return <String, dynamic>{
                    'id': acc.id,
                    'name': acc.name,
                    'balance': 0.0,
                    'balanceMinor': '0',
                  };
                },
              },
          logger: _FakeLoggerService(),
        );

        final LocalToCloudMigrationLocalOwnershipConversionService
        conversionService =
            LocalToCloudMigrationLocalOwnershipConversionService(
              database: database,
              outboxDao: outboxDao,
              migrationStateRepository: migrationStateRepo,
              logger: _FakeLoggerService(),
            );

        final CloudActivationExecutionService executionService =
            CloudActivationExecutionService(
              firestore: firestore,
              uploadService: uploadService,
              remoteVerificationService: verificationService,
              localOwnershipConversionService: conversionService,
              activationStateRepository: activationStateRepo,
              migrationStateRepository: migrationStateRepo,
              entitlementRepository: _FakeCloudEntitlementRepository(
                CloudEntitlementState.active,
              ),
              localSnapshotSummaryService: LocalSnapshotSummaryService(
                database: database,
                outboxDao: outboxDao,
                activationRuntimeGuard: CloudActivationRuntimeGuard(),
              ),
              cloudSnapshotSummaryService: CloudSnapshotSummaryService(
                firestore: firestore,
              ),
              localToCloudMigrationReadinessService:
                  _FakeLocalToCloudMigrationReadinessService(preflightResult),
              prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
                bundle,
              ),
              exportUserDataUseCase: _FakeExportUserDataUseCase(
                ExportFileSaveResult.success(filePath: '/tmp/test-backup.json'),
              ),
              userAccountCleanupRepository: _FakeUserAccountCleanupRepository(),
              runtimeGuard: CloudActivationRuntimeGuard(),
              logger: _FakeLoggerService(),
            );

        // Preflight
        final CloudActivationExecutionResult preflightRes =
            await executionService.confirmMigrateLocalToCloudPreflight(
              currentUser: testUser,
              intentState: intentState,
              currentMode: currentMode,
            );
        expect(preflightRes.status, CloudActivationExecutionStatus.succeeded);

        // Execution attempt 1 (should fail network error)
        DataModeState simulatedMode = currentMode;
        final CloudActivationExecutionResult execRes1 = await executionService
            .confirmMigrateLocalToCloudExecution(
              currentUser: testUser,
              intentState: intentState,
              currentMode: simulatedMode,
              refreshRuntimeMode: () async => simulatedMode,
            );

        expect(execRes1.status, CloudActivationExecutionStatus.blocked);
        expect(
          execRes1.blockReason,
          CloudActivationExecutionBlockReason.migrationNetworkRetryable,
        );
        expect(
          migrationStateRepo.state!.stage,
          LocalToCloudMigrationStage.uploadPartiallyCompleted,
        );
        expect(
          migrationStateRepo.state!.uploadedRowCountsByFamily['accounts'],
          1,
        );

        // Check remote marker status remains uploadInProgress
        final DocumentSnapshot<Map<String, dynamic>> markerAfterFail =
            await firestore
                .doc('users/${testUser.uid}/migration_state/status')
                .get();
        expect(markerAfterFail.data()!['stage'], 'uploadInProgress');

        // Now enable second document upload (fix network)
        throwOnSecond = false;

        final CloudActivationExecutionResult execRes2 = await executionService
            .confirmMigrateLocalToCloudExecution(
              currentUser: testUser,
              intentState: intentState,
              currentMode: simulatedMode,
              refreshRuntimeMode: () async {
                currentUid = testUser.uid;
                simulatedMode = const DataModeState(
                  dataMode: DataMode.cloudEnabled,
                  entitlementState: CloudEntitlementState.active,
                  migrationDecision: MigrationDecision.none,
                );
                return simulatedMode;
              },
            );
        expect(execRes2.status, CloudActivationExecutionStatus.succeeded);
        expect(
          migrationStateRepo.state!.stage,
          LocalToCloudMigrationStage.completed,
        );

        // Verify remote marker status is completed
        final DocumentSnapshot<Map<String, dynamic>> markerAfterSuccess =
            await firestore
                .doc('users/${testUser.uid}/migration_state/status')
                .get();
        expect(markerAfterSuccess.data()!['stage'], 'completed');
      },
    );

    test('Failure Path: UID changed blocks execution', () async {
      final DateTime now = DateTime.utc(2024, 1, 1);
      await database
          .into(database.accounts)
          .insert(
            db.AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Cash',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );
      final ExportBundle bundle = buildBundle(
        accounts: const <AccountEntity>[],
        transactions: const <TransactionEntity>[],
      );

      const LocalToCloudMigrationPreflightResult preflightResult =
          LocalToCloudMigrationPreflightResult.ready(
            localSummary: LocalSnapshotSummary(
              state: LocalSnapshotState.hasUserData,
              hasUserData: true,
              hasSystemData: false,
              pendingOutboxCount: 0,
              fingerprint: 'local:hasUserData|user:true|system:false|outbox:0',
            ),
            inventorySnapshot: LocalToCloudMigrationInventorySnapshot(
              candidateFamilyKeys: <String>{},
              rowsByFamily: <String, List<LocalToCloudMigrationRow>>{},
            ),
            readinessResult: LocalToCloudMigrationReadinessResult(
              status: LocalToCloudMigrationReadinessStatus.ready,
              issues: <LocalToCloudMigrationReadinessIssue>[],
            ),
          );

      // Setup state repo initialized for user-123
      migrationStateRepo.state = LocalToCloudMigrationState(
        uid: 'user-123',
        stage: LocalToCloudMigrationStage.backupCreated,
        createdAt: now,
        updatedAt: now,
        plan: LocalToCloudMigrationPlan(
          migrationId: 'ltc-1',
          createdAt: now,
          localFingerprint: 'local:hasUserData|user:true|system:false|outbox:0',
          remoteFingerprint: 'remote:empty|active:false|meta:false|tomb:false',
          candidateFamilyKeys: const <String>[],
          rows: const <LocalToCloudMigrationPlanRow>[],
        ),
        version: 2,
      );

      final CloudActivationExecutionService
      executionService = CloudActivationExecutionService(
        firestore: firestore,
        uploadService: LocalToCloudMigrationUploadService(
          firestore: firestore,
          migrationStateRepository: migrationStateRepo,
          prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(bundle),
          uploaders: const <String, LocalToCloudMigrationEntityUploader>{},
          logger: _FakeLoggerService(),
        ),
        remoteVerificationService:
            LocalToCloudMigrationRemoteVerificationService(
              migrationStateRepository: migrationStateRepo,
              prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
                bundle,
              ),
              readers:
                  const <String, LocalToCloudMigrationRemoteCollectionReader>{},
              expectedPayloadBuilders:
                  const <
                    String,
                    LocalToCloudMigrationExpectedRemotePayloadBuilder
                  >{},
              logger: _FakeLoggerService(),
            ),
        localOwnershipConversionService:
            LocalToCloudMigrationLocalOwnershipConversionService(
              database: database,
              outboxDao: outboxDao,
              migrationStateRepository: migrationStateRepo,
              logger: _FakeLoggerService(),
            ),
        activationStateRepository: activationStateRepo,
        migrationStateRepository: migrationStateRepo,
        entitlementRepository: _FakeCloudEntitlementRepository(
          CloudEntitlementState.active,
        ),
        localSnapshotSummaryService: LocalSnapshotSummaryService(
          database: database,
          outboxDao: outboxDao,
          activationRuntimeGuard: CloudActivationRuntimeGuard(),
        ),
        cloudSnapshotSummaryService: CloudSnapshotSummaryService(
          firestore: firestore,
        ),
        localToCloudMigrationReadinessService:
            _FakeLocalToCloudMigrationReadinessService(preflightResult),
        prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(bundle),
        exportUserDataUseCase: _FakeExportUserDataUseCase(
          ExportFileSaveResult.success(filePath: '/tmp/test-backup.json'),
        ),
        userAccountCleanupRepository: _FakeUserAccountCleanupRepository(),
        runtimeGuard: CloudActivationRuntimeGuard(),
        logger: _FakeLoggerService(),
      );

      const AuthUser wrongUser = AuthUser(
        uid: 'user-456',
        email: 'wrong@example.com',
        isAnonymous: false,
      );

      final CloudActivationExecutionResult execRes = await executionService
          .confirmMigrateLocalToCloudExecution(
            currentUser: wrongUser,
            intentState: intentState,
            currentMode: currentMode,
            refreshRuntimeMode: () async => currentMode,
          );

      expect(execRes.status, CloudActivationExecutionStatus.blocked);
      expect(
        execRes.blockReason,
        CloudActivationExecutionBlockReason.migrationUidChanged,
      );
    });

    test(
      'Guards: verify write-freeze blocks local mutations in intermediate stages',
      () async {
        final _FakeMigrationFreezeStateRepository freezeRepo =
            _FakeMigrationFreezeStateRepository();
        final MigrationWriteGuard writeGuard = SharedPrefsMigrationWriteGuard(
          database: database,
          stateRepository: freezeRepo,
        );

        // Activate freeze
        await writeGuard.activateFreeze(uid: 'user-123', phase: 'upload');

        // Outbox mutations must be blocked
        expect(
          () => writeGuard.ensureOutboxMutationAllowed(entityType: 'account'),
          throwsA(isA<MigrationFreezeActive>()),
        );
      },
    );
  });
}
