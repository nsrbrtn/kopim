import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/cloud_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_snapshot_builder.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_readiness_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_execution_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_runtime_guard.dart';
import 'package:kopim/features/profile/application/migration_write_guard.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/cloud_activation_state.dart';
import 'package:kopim/features/profile/domain/repositories/user_account_cleanup_repository.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/use_cases/export_user_data_use_case.dart';

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
  Future<CloudEntitlementResult> activateKey(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearEntitlement() async {}

  @override
  Future<CloudEntitlementState> getCachedState() async => state;
}

class _FakeCloudActivationStateRepository
    implements CloudActivationStateRepository {
  CloudActivationState? savedState;

  @override
  Future<void> clearStateForUid(String uid) async {
    if (savedState?.uid == uid) {
      savedState = null;
    }
  }

  @override
  Future<CloudActivationState?> getStateForUid(String uid) async {
    if (savedState?.uid == uid) {
      return savedState;
    }
    return null;
  }

  @override
  Future<void> saveEnabledState({
    required String uid,
    required String scenario,
    required String? localFingerprint,
    required String? remoteFingerprint,
  }) async {
    savedState = CloudActivationState(
      uid: uid,
      scenario: scenario,
      activatedAt: DateTime.utc(2024, 1, 1),
      localFingerprint: localFingerprint,
      remoteFingerprint: remoteFingerprint,
      version: 1,
    );
  }
}

class _FakeLocalSnapshotSummaryService extends LocalSnapshotSummaryService {
  _FakeLocalSnapshotSummaryService(this._summary)
    : super(
        database: AppDatabase.connect(
          DatabaseConnection(NativeDatabase.memory()),
        ),
        outboxDao: OutboxDao(
          AppDatabase.connect(DatabaseConnection(NativeDatabase.memory())),
          () => null,
        ),
        activationRuntimeGuard: CloudActivationRuntimeGuard(),
      );

  final LocalSnapshotSummary _summary;
  LocalSnapshotSummary? postResetSummary;
  bool isResetDone = false;

  @override
  Future<LocalSnapshotSummary> summarize({
    bool includeActivationGuard = true,
  }) async {
    if (isResetDone && postResetSummary != null) {
      return postResetSummary!;
    }
    return _summary;
  }
}

class _FakeCloudSnapshotSummaryService extends CloudSnapshotSummaryService {
  _FakeCloudSnapshotSummaryService(this._summary)
    : super(firestore: FakeFirebaseFirestore());

  final CloudSnapshotSummary _summary;
  CloudSnapshotSummary? guardedSummary;
  int callCount = 0;

  @override
  Future<CloudSnapshotSummary> summarize(String uid) async {
    callCount += 1;
    if (callCount > 1 && guardedSummary != null) {
      return guardedSummary!;
    }
    return _summary;
  }
}

class _FakeExportUserDataUseCase implements ExportUserDataUseCase {
  _FakeExportUserDataUseCase(this.result);

  ExportFileSaveResult result;
  int callCount = 0;

  @override
  Future<ExportFileSaveResult> call(ExportUserDataParams params) async {
    callCount += 1;
    return result;
  }
}

class _FakeUserAccountCleanupRepository
    implements UserAccountCleanupRepository {
  int deleteLocalUserDataCallCount = 0;
  bool shouldThrow = false;
  void Function()? onReset;

  @override
  Future<void> deleteLocalUserData(String uid) async {
    deleteLocalUserDataCallCount += 1;
    if (shouldThrow) {
      throw Exception('database_reset_failed');
    }
    onReset?.call();
  }

  @override
  Future<void> deleteRemoteUserData(String uid) {
    throw UnimplementedError();
  }
}

class _FakeLocalToCloudMigrationReadinessService
    extends LocalToCloudMigrationReadinessService {
  _FakeLocalToCloudMigrationReadinessService(this.result)
    : super(
        migrationWriteGuard: const NoopMigrationWriteGuard(),
        localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(
          const LocalSnapshotSummary(
            state: LocalSnapshotState.hasUserData,
            hasUserData: true,
            hasSystemData: true,
            pendingOutboxCount: 0,
            fingerprint: 'local:hasUserData',
          ),
        ),
        snapshotBuilder: LocalToCloudMigrationInventorySnapshotBuilder(
          AppDatabase.connect(DatabaseConnection(NativeDatabase.memory())),
        ),
        inventoryValidator: LocalToCloudMigrationInventoryValidator(
          policy: LocalToCloudMigrationInventoryPolicy(),
        ),
      );

  final LocalToCloudMigrationPreflightResult result;
  int callCount = 0;

  @override
  Future<LocalToCloudMigrationPreflightResult> captureReadiness({
    String? uid,
  }) async {
    callCount += 1;
    return result;
  }
}

CloudActivationExecutionService _buildService({
  required CloudActivationStateRepository activationStateRepository,
  required CloudEntitlementRepository entitlementRepository,
  required LocalSnapshotSummaryService localSnapshotSummaryService,
  required CloudSnapshotSummaryService cloudSnapshotSummaryService,
  LocalToCloudMigrationReadinessService? localToCloudMigrationReadinessService,
  ExportUserDataUseCase? exportUserDataUseCase,
  UserAccountCleanupRepository? userAccountCleanupRepository,
}) {
  return CloudActivationExecutionService(
    activationStateRepository: activationStateRepository,
    entitlementRepository: entitlementRepository,
    localSnapshotSummaryService: localSnapshotSummaryService,
    cloudSnapshotSummaryService: cloudSnapshotSummaryService,
    localToCloudMigrationReadinessService:
        localToCloudMigrationReadinessService ??
        _FakeLocalToCloudMigrationReadinessService(
          const LocalToCloudMigrationPreflightResult.blocked(
            reason: LocalToCloudMigrationPreflightBlockReason
                .inventoryReadinessBlocked,
            readinessResult: LocalToCloudMigrationReadinessResult(
              status: LocalToCloudMigrationReadinessStatus.blocked,
              issues: <LocalToCloudMigrationReadinessIssue>[
                LocalToCloudMigrationReadinessIssue(
                  code:
                      LocalToCloudMigrationReadinessReasonCode.unsafeDocumentId,
                  familyKey: 'transactions',
                  rowId: 'tx-unsafe',
                  message: 'Unsafe transaction document ID.',
                ),
              ],
            ),
          ),
        ),
    exportUserDataUseCase:
        exportUserDataUseCase ??
        _FakeExportUserDataUseCase(
          ExportFileSaveResult.success(filePath: '/tmp/kopim-export.json'),
        ),
    userAccountCleanupRepository:
        userAccountCleanupRepository ?? _FakeUserAccountCleanupRepository(),
    runtimeGuard: CloudActivationRuntimeGuard(),
    logger: _FakeLoggerService(),
  );
}

void main() {
  setUp(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
  });

  test(
    'succeeds for empty local and empty remote after persisting flag',
    () async {
      final _FakeCloudActivationStateRepository activationRepository =
          _FakeCloudActivationStateRepository();
      final CloudActivationExecutionService service = _buildService(
        activationStateRepository: activationRepository,
        entitlementRepository: _FakeCloudEntitlementRepository(
          CloudEntitlementState.active,
        ),
        localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(
          const LocalSnapshotSummary(
            state: LocalSnapshotState.empty,
            hasUserData: false,
            hasSystemData: false,
            pendingOutboxCount: 0,
            fingerprint: 'local:empty',
          ),
        ),
        cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(
          const CloudSnapshotSummary(
            state: RemoteSnapshotState.empty,
            hasUserData: false,
            hasMetadata: false,
            hasTombstonesOnly: false,
            fingerprint: 'remote:empty|uid:cloud-user-1',
          ),
        ),
      );

      final CloudActivationExecutionResult result = await service
          .confirmEnableCloudSync(
            currentUser: const AuthUser(
              uid: 'cloud-user-1',
              email: 'user@example.com',
              isAnonymous: false,
            ),
            intentState: const CloudActivationIntentState(
              pendingChoice: CloudActivationChoice.enableCloudSync,
              stage: CloudActivationIntentStage.pendingChoice,
              scenario: CloudActivationScenario.localEmptyRemoteEmpty,
              localSnapshotState: CloudActivationSnapshotState.empty,
              remoteSnapshotState: CloudActivationSnapshotState.empty,
              localFingerprint: 'local:empty',
              remoteFingerprint: 'remote:empty|uid:cloud-user-1',
            ),
            currentMode: const DataModeState(
              dataMode: DataMode.localOnly,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
            refreshRuntimeMode: () async => const DataModeState(
              dataMode: DataMode.cloudEnabled,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          );

      expect(result.status, CloudActivationExecutionStatus.succeeded);
      expect(activationRepository.savedState, isNotNull);
      expect(activationRepository.savedState!.uid, 'cloud-user-1');
    },
  );

  test('blocks metadata-only remote state in v1', () async {
    final CloudActivationExecutionService service = _buildService(
      activationStateRepository: _FakeCloudActivationStateRepository(),
      entitlementRepository: _FakeCloudEntitlementRepository(
        CloudEntitlementState.active,
      ),
      localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(
        const LocalSnapshotSummary(
          state: LocalSnapshotState.empty,
          hasUserData: false,
          hasSystemData: false,
          pendingOutboxCount: 0,
          fingerprint: 'local:empty',
        ),
      ),
      cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(
        const CloudSnapshotSummary(
          state: RemoteSnapshotState.hasOnlyMetadata,
          hasUserData: false,
          hasMetadata: true,
          hasTombstonesOnly: false,
          fingerprint: 'remote:hasOnlyMetadata|uid:cloud-user-1',
        ),
      ),
    );

    final CloudActivationExecutionResult result = await service
        .confirmEnableCloudSync(
          currentUser: const AuthUser(
            uid: 'cloud-user-1',
            email: 'user@example.com',
            isAnonymous: false,
          ),
          intentState: const CloudActivationIntentState(
            pendingChoice: CloudActivationChoice.enableCloudSync,
            stage: CloudActivationIntentStage.pendingChoice,
            scenario: CloudActivationScenario.localEmptyRemoteMetadataOnly,
            localSnapshotState: CloudActivationSnapshotState.empty,
            remoteSnapshotState: CloudActivationSnapshotState.empty,
            localFingerprint: 'local:empty',
            remoteFingerprint: 'remote:hasOnlyMetadata|uid:cloud-user-1',
          ),
          currentMode: const DataModeState(
            dataMode: DataMode.localOnly,
            entitlementState: CloudEntitlementState.active,
            migrationDecision: MigrationDecision.none,
          ),
          refreshRuntimeMode: () async => const DataModeState(
            dataMode: DataMode.localOnly,
            entitlementState: CloudEntitlementState.active,
            migrationDecision: MigrationDecision.none,
          ),
        );

    expect(result.status, CloudActivationExecutionStatus.blocked);
    expect(
      result.blockReason,
      CloudActivationExecutionBlockReason.remoteMetadataPresent,
    );
  });

  test(
    'startWithEmptyCloud exports, clears local data and enables cloud',
    () async {
      final _FakeCloudActivationStateRepository activationRepository =
          _FakeCloudActivationStateRepository();
      final _FakeExportUserDataUseCase exportUseCase =
          _FakeExportUserDataUseCase(
            ExportFileSaveResult.success(filePath: '/tmp/kopim-export.json'),
          );
      final _FakeLocalSnapshotSummaryService localSummaryService =
          _FakeLocalSnapshotSummaryService(
              const LocalSnapshotSummary(
                state: LocalSnapshotState.hasUserData,
                hasUserData: true,
                hasSystemData: true,
                pendingOutboxCount: 0,
                fingerprint: 'local:hasUserData',
              ),
            )
            ..postResetSummary = const LocalSnapshotSummary(
              state: LocalSnapshotState.empty,
              hasUserData: false,
              hasSystemData: false,
              pendingOutboxCount: 0,
              fingerprint: 'local:empty',
            );
      final _FakeUserAccountCleanupRepository cleanupRepository =
          _FakeUserAccountCleanupRepository()
            ..onReset = () {
              localSummaryService.isResetDone = true;
            };
      final CloudActivationExecutionService service = _buildService(
        activationStateRepository: activationRepository,
        entitlementRepository: _FakeCloudEntitlementRepository(
          CloudEntitlementState.active,
        ),
        localSnapshotSummaryService: localSummaryService,
        cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(
          const CloudSnapshotSummary(
            state: RemoteSnapshotState.empty,
            hasUserData: false,
            hasMetadata: false,
            hasTombstonesOnly: false,
            fingerprint: 'remote:empty|uid:cloud-user-1',
          ),
        ),
        exportUserDataUseCase: exportUseCase,
        userAccountCleanupRepository: cleanupRepository,
      );

      final CloudActivationExecutionResult result = await service
          .confirmStartWithEmptyCloud(
            currentUser: const AuthUser(
              uid: 'cloud-user-1',
              email: 'user@example.com',
              isAnonymous: false,
            ),
            intentState: const CloudActivationIntentState(
              pendingChoice: CloudActivationChoice.startWithEmptyCloud,
              stage: CloudActivationIntentStage.pendingChoice,
              scenario: CloudActivationScenario.localHasDataRemoteEmpty,
              localSnapshotState: CloudActivationSnapshotState.hasData,
              remoteSnapshotState: CloudActivationSnapshotState.empty,
              localFingerprint: 'local:hasUserData',
              remoteFingerprint: 'remote:empty|uid:cloud-user-1',
            ),
            currentMode: const DataModeState(
              dataMode: DataMode.localOnly,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
            refreshRuntimeMode: () async => const DataModeState(
              dataMode: DataMode.cloudEnabled,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          );

      expect(result.status, CloudActivationExecutionStatus.succeeded);
      expect(result.message, contains('/tmp/kopim-export.json'));
      expect(exportUseCase.callCount, 1);
      expect(cleanupRepository.deleteLocalUserDataCallCount, 1);
      expect(activationRepository.savedState, isNotNull);
      expect(
        activationRepository.savedState!.scenario,
        CloudActivationChoice.startWithEmptyCloud.name,
      );
    },
  );

  test(
    'startWithEmptyCloud stays fail-closed when backup export fails',
    () async {
      final _FakeCloudActivationStateRepository activationRepository =
          _FakeCloudActivationStateRepository();
      final _FakeUserAccountCleanupRepository cleanupRepository =
          _FakeUserAccountCleanupRepository();
      final CloudActivationExecutionService service = _buildService(
        activationStateRepository: activationRepository,
        entitlementRepository: _FakeCloudEntitlementRepository(
          CloudEntitlementState.active,
        ),
        localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(
          const LocalSnapshotSummary(
            state: LocalSnapshotState.hasUserData,
            hasUserData: true,
            hasSystemData: true,
            pendingOutboxCount: 0,
            fingerprint: 'local:hasUserData',
          ),
        ),
        cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(
          const CloudSnapshotSummary(
            state: RemoteSnapshotState.empty,
            hasUserData: false,
            hasMetadata: false,
            hasTombstonesOnly: false,
            fingerprint: 'remote:empty|uid:cloud-user-1',
          ),
        ),
        exportUserDataUseCase: _FakeExportUserDataUseCase(
          ExportFileSaveResult.failure('export failed'),
        ),
        userAccountCleanupRepository: cleanupRepository,
      );

      final CloudActivationExecutionResult result = await service
          .confirmStartWithEmptyCloud(
            currentUser: const AuthUser(
              uid: 'cloud-user-1',
              email: 'user@example.com',
              isAnonymous: false,
            ),
            intentState: const CloudActivationIntentState(
              pendingChoice: CloudActivationChoice.startWithEmptyCloud,
              stage: CloudActivationIntentStage.pendingChoice,
              scenario: CloudActivationScenario.localHasDataRemoteEmpty,
              localSnapshotState: CloudActivationSnapshotState.hasData,
              remoteSnapshotState: CloudActivationSnapshotState.empty,
              localFingerprint: 'local:hasUserData',
              remoteFingerprint: 'remote:empty|uid:cloud-user-1',
            ),
            currentMode: const DataModeState(
              dataMode: DataMode.localOnly,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
            refreshRuntimeMode: () async => const DataModeState(
              dataMode: DataMode.cloudEnabled,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          );

      expect(result.status, CloudActivationExecutionStatus.failed);
      expect(
        result.blockReason,
        CloudActivationExecutionBlockReason.backupExportFailed,
      );
      expect(cleanupRepository.deleteLocalUserDataCallCount, 0);
      expect(activationRepository.savedState, isNull);
    },
  );

  test('startWithEmptyCloud fails when SQLite reset fails', () async {
    final _FakeCloudActivationStateRepository activationRepository =
        _FakeCloudActivationStateRepository();
    final _FakeLocalSnapshotSummaryService localSummaryService =
        _FakeLocalSnapshotSummaryService(
            const LocalSnapshotSummary(
              state: LocalSnapshotState.hasUserData,
              hasUserData: true,
              hasSystemData: true,
              pendingOutboxCount: 0,
              fingerprint: 'local:hasUserData',
            ),
          )
          ..postResetSummary = const LocalSnapshotSummary(
            state: LocalSnapshotState.empty,
            hasUserData: false,
            hasSystemData: false,
            pendingOutboxCount: 0,
            fingerprint: 'local:empty',
          );
    final _FakeUserAccountCleanupRepository cleanupRepository =
        _FakeUserAccountCleanupRepository()
          ..shouldThrow = true
          ..onReset = () {
            localSummaryService.isResetDone = true;
          };
    final CloudActivationExecutionService service = _buildService(
      activationStateRepository: activationRepository,
      entitlementRepository: _FakeCloudEntitlementRepository(
        CloudEntitlementState.active,
      ),
      localSnapshotSummaryService: localSummaryService,
      cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(
        const CloudSnapshotSummary(
          state: RemoteSnapshotState.empty,
          hasUserData: false,
          hasMetadata: false,
          hasTombstonesOnly: false,
          fingerprint: 'remote:empty|uid:cloud-user-1',
        ),
      ),
      userAccountCleanupRepository: cleanupRepository,
    );

    final CloudActivationExecutionResult result = await service
        .confirmStartWithEmptyCloud(
          currentUser: const AuthUser(
            uid: 'cloud-user-1',
            email: 'user@example.com',
            isAnonymous: false,
          ),
          intentState: const CloudActivationIntentState(
            pendingChoice: CloudActivationChoice.startWithEmptyCloud,
            stage: CloudActivationIntentStage.pendingChoice,
            scenario: CloudActivationScenario.localHasDataRemoteEmpty,
            localSnapshotState: CloudActivationSnapshotState.hasData,
            remoteSnapshotState: CloudActivationSnapshotState.empty,
            localFingerprint: 'local:hasUserData',
            remoteFingerprint: 'remote:empty|uid:cloud-user-1',
          ),
          currentMode: const DataModeState(
            dataMode: DataMode.localOnly,
            entitlementState: CloudEntitlementState.active,
            migrationDecision: MigrationDecision.none,
          ),
          refreshRuntimeMode: () async => const DataModeState(
            dataMode: DataMode.cloudEnabled,
            entitlementState: CloudEntitlementState.active,
            migrationDecision: MigrationDecision.none,
          ),
        );

    expect(result.status, CloudActivationExecutionStatus.failed);
    expect(
      result.blockReason,
      CloudActivationExecutionBlockReason.localResetFailed,
    );
    expect(cleanupRepository.deleteLocalUserDataCallCount, 1);
    expect(activationRepository.savedState, isNull);
  });

  test(
    'startWithEmptyCloud fails when remote revalidation detects user data',
    () async {
      final _FakeCloudActivationStateRepository activationRepository =
          _FakeCloudActivationStateRepository();
      final _FakeLocalSnapshotSummaryService localSummaryService =
          _FakeLocalSnapshotSummaryService(
              const LocalSnapshotSummary(
                state: LocalSnapshotState.hasUserData,
                hasUserData: true,
                hasSystemData: true,
                pendingOutboxCount: 0,
                fingerprint: 'local:hasUserData',
              ),
            )
            ..postResetSummary = const LocalSnapshotSummary(
              state: LocalSnapshotState.empty,
              hasUserData: false,
              hasSystemData: false,
              pendingOutboxCount: 0,
              fingerprint: 'local:empty',
            );
      final _FakeUserAccountCleanupRepository cleanupRepository =
          _FakeUserAccountCleanupRepository()
            ..onReset = () {
              localSummaryService.isResetDone = true;
            };
      final _FakeCloudSnapshotSummaryService cloudSummaryService =
          _FakeCloudSnapshotSummaryService(
              const CloudSnapshotSummary(
                state: RemoteSnapshotState.empty,
                hasUserData: false,
                hasMetadata: false,
                hasTombstonesOnly: false,
                fingerprint: 'remote:empty|uid:cloud-user-1',
              ),
            )
            ..guardedSummary = const CloudSnapshotSummary(
              state: RemoteSnapshotState.hasUserData,
              hasUserData: true,
              hasMetadata: false,
              hasTombstonesOnly: false,
              fingerprint: 'remote:hasUserData|uid:cloud-user-1',
            );

      final CloudActivationExecutionService service = _buildService(
        activationStateRepository: activationRepository,
        entitlementRepository: _FakeCloudEntitlementRepository(
          CloudEntitlementState.active,
        ),
        localSnapshotSummaryService: localSummaryService,
        cloudSnapshotSummaryService: cloudSummaryService,
        userAccountCleanupRepository: cleanupRepository,
      );

      final CloudActivationExecutionResult result = await service
          .confirmStartWithEmptyCloud(
            currentUser: const AuthUser(
              uid: 'cloud-user-1',
              email: 'user@example.com',
              isAnonymous: false,
            ),
            intentState: const CloudActivationIntentState(
              pendingChoice: CloudActivationChoice.startWithEmptyCloud,
              stage: CloudActivationIntentStage.pendingChoice,
              scenario: CloudActivationScenario.localHasDataRemoteEmpty,
              localSnapshotState: CloudActivationSnapshotState.hasData,
              remoteSnapshotState: CloudActivationSnapshotState.empty,
              localFingerprint: 'local:hasUserData',
              remoteFingerprint: 'remote:empty|uid:cloud-user-1',
            ),
            currentMode: const DataModeState(
              dataMode: DataMode.localOnly,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
            refreshRuntimeMode: () async => const DataModeState(
              dataMode: DataMode.cloudEnabled,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          );

      expect(result.status, CloudActivationExecutionStatus.blocked);
      expect(
        result.blockReason,
        CloudActivationExecutionBlockReason.remoteNotEmpty,
      );
      expect(cleanupRepository.deleteLocalUserDataCallCount, 0);
      expect(activationRepository.savedState, isNull);
    },
  );

  test(
    'startWithEmptyCloud fails when post-reset summary check fails',
    () async {
      final _FakeCloudActivationStateRepository activationRepository =
          _FakeCloudActivationStateRepository();
      final _FakeLocalSnapshotSummaryService localSummaryService =
          _FakeLocalSnapshotSummaryService(
              const LocalSnapshotSummary(
                state: LocalSnapshotState.hasUserData,
                hasUserData: true,
                hasSystemData: true,
                pendingOutboxCount: 0,
                fingerprint: 'local:hasUserData',
              ),
            )
            ..postResetSummary = const LocalSnapshotSummary(
              // Симулируем, что база данных осталась "грязной" после сброса
              state: LocalSnapshotState.hasUserData,
              hasUserData: true,
              hasSystemData: true,
              pendingOutboxCount: 0,
              fingerprint: 'local:stillHasUserData',
            );
      final _FakeUserAccountCleanupRepository cleanupRepository =
          _FakeUserAccountCleanupRepository()
            ..onReset = () {
              localSummaryService.isResetDone = true;
            };
      final CloudActivationExecutionService service = _buildService(
        activationStateRepository: activationRepository,
        entitlementRepository: _FakeCloudEntitlementRepository(
          CloudEntitlementState.active,
        ),
        localSnapshotSummaryService: localSummaryService,
        cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(
          const CloudSnapshotSummary(
            state: RemoteSnapshotState.empty,
            hasUserData: false,
            hasMetadata: false,
            hasTombstonesOnly: false,
            fingerprint: 'remote:empty|uid:cloud-user-1',
          ),
        ),
        userAccountCleanupRepository: cleanupRepository,
      );

      final CloudActivationExecutionResult result = await service
          .confirmStartWithEmptyCloud(
            currentUser: const AuthUser(
              uid: 'cloud-user-1',
              email: 'user@example.com',
              isAnonymous: false,
            ),
            intentState: const CloudActivationIntentState(
              pendingChoice: CloudActivationChoice.startWithEmptyCloud,
              stage: CloudActivationIntentStage.pendingChoice,
              scenario: CloudActivationScenario.localHasDataRemoteEmpty,
              localSnapshotState: CloudActivationSnapshotState.hasData,
              remoteSnapshotState: CloudActivationSnapshotState.empty,
              localFingerprint: 'local:hasUserData',
              remoteFingerprint: 'remote:empty|uid:cloud-user-1',
            ),
            currentMode: const DataModeState(
              dataMode: DataMode.localOnly,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
            refreshRuntimeMode: () async => const DataModeState(
              dataMode: DataMode.cloudEnabled,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          );

      expect(result.status, CloudActivationExecutionStatus.failed);
      expect(
        result.blockReason,
        CloudActivationExecutionBlockReason.localResetFailed,
      );
      expect(cleanupRepository.deleteLocalUserDataCallCount, 1);
      expect(activationRepository.savedState, isNull);
    },
  );

  test(
    'migrateLocalToCloud preflight blocks when inventory readiness is blocked',
    () async {
      final _FakeLocalToCloudMigrationReadinessService
      readinessService = _FakeLocalToCloudMigrationReadinessService(
        const LocalToCloudMigrationPreflightResult.blocked(
          reason: LocalToCloudMigrationPreflightBlockReason
              .inventoryReadinessBlocked,
          readinessResult: LocalToCloudMigrationReadinessResult(
            status: LocalToCloudMigrationReadinessStatus.blocked,
            issues: <LocalToCloudMigrationReadinessIssue>[
              LocalToCloudMigrationReadinessIssue(
                code: LocalToCloudMigrationReadinessReasonCode.unsafeDocumentId,
                familyKey: 'transactions',
                rowId: 'tx-unsafe',
                message: 'Unsafe transaction document ID.',
              ),
            ],
          ),
        ),
      );
      final CloudActivationExecutionService service = _buildService(
        activationStateRepository: _FakeCloudActivationStateRepository(),
        entitlementRepository: _FakeCloudEntitlementRepository(
          CloudEntitlementState.active,
        ),
        localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(
          const LocalSnapshotSummary(
            state: LocalSnapshotState.hasUserData,
            hasUserData: true,
            hasSystemData: true,
            pendingOutboxCount: 0,
            fingerprint: 'local:hasUserData',
          ),
        ),
        cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(
          const CloudSnapshotSummary(
            state: RemoteSnapshotState.empty,
            hasUserData: false,
            hasMetadata: false,
            hasTombstonesOnly: false,
            fingerprint: 'remote:empty|uid:cloud-user-1',
          ),
        ),
        localToCloudMigrationReadinessService: readinessService,
      );

      final CloudActivationExecutionResult result = await service
          .confirmMigrateLocalToCloudPreflight(
            currentUser: const AuthUser(
              uid: 'cloud-user-1',
              email: 'user@example.com',
              isAnonymous: false,
            ),
            intentState: const CloudActivationIntentState(
              pendingChoice: CloudActivationChoice.migrateLocalToCloud,
              stage: CloudActivationIntentStage.pendingChoice,
              scenario: CloudActivationScenario.localHasDataRemoteEmpty,
              localSnapshotState: CloudActivationSnapshotState.hasData,
              remoteSnapshotState: CloudActivationSnapshotState.empty,
              localFingerprint: 'local:hasUserData',
              remoteFingerprint: 'remote:empty|uid:cloud-user-1',
            ),
            currentMode: const DataModeState(
              dataMode: DataMode.localOnly,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          );

      expect(result.status, CloudActivationExecutionStatus.blocked);
      expect(
        result.blockReason,
        CloudActivationExecutionBlockReason.migrationReadinessBlocked,
      );
      expect(result.message, 'Unsafe transaction document ID.');
      expect(readinessService.callCount, 1);
    },
  );

  test(
    'migrateLocalToCloud preflight reports not implemented when readiness is ready',
    () async {
      final _FakeLocalToCloudMigrationReadinessService readinessService =
          _FakeLocalToCloudMigrationReadinessService(
            const LocalToCloudMigrationPreflightResult.ready(
              localSummary: LocalSnapshotSummary(
                state: LocalSnapshotState.hasUserData,
                hasUserData: true,
                hasSystemData: true,
                pendingOutboxCount: 0,
                fingerprint: 'local:hasUserData',
              ),
              inventorySnapshot: LocalToCloudMigrationInventorySnapshot(
                candidateFamilyKeys: <String>{'transactions'},
                rowsByFamily: <String, List<LocalToCloudMigrationRow>>{
                  'transactions': <LocalToCloudMigrationRow>[
                    LocalToCloudMigrationRow(
                      familyKey: 'transactions',
                      localRowId: 'tx-1',
                      reusedDocumentId: 'tx-1',
                    ),
                  ],
                },
              ),
              readinessResult: LocalToCloudMigrationReadinessResult.ready(),
            ),
          );
      final CloudActivationExecutionService service = _buildService(
        activationStateRepository: _FakeCloudActivationStateRepository(),
        entitlementRepository: _FakeCloudEntitlementRepository(
          CloudEntitlementState.active,
        ),
        localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(
          const LocalSnapshotSummary(
            state: LocalSnapshotState.hasUserData,
            hasUserData: true,
            hasSystemData: true,
            pendingOutboxCount: 0,
            fingerprint: 'local:hasUserData',
          ),
        ),
        cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(
          const CloudSnapshotSummary(
            state: RemoteSnapshotState.empty,
            hasUserData: false,
            hasMetadata: false,
            hasTombstonesOnly: false,
            fingerprint: 'remote:empty|uid:cloud-user-1',
          ),
        ),
        localToCloudMigrationReadinessService: readinessService,
      );

      final CloudActivationExecutionResult result = await service
          .confirmMigrateLocalToCloudPreflight(
            currentUser: const AuthUser(
              uid: 'cloud-user-1',
              email: 'user@example.com',
              isAnonymous: false,
            ),
            intentState: const CloudActivationIntentState(
              pendingChoice: CloudActivationChoice.migrateLocalToCloud,
              stage: CloudActivationIntentStage.pendingChoice,
              scenario: CloudActivationScenario.localHasDataRemoteEmpty,
              localSnapshotState: CloudActivationSnapshotState.hasData,
              remoteSnapshotState: CloudActivationSnapshotState.empty,
              localFingerprint: 'local:hasUserData',
              remoteFingerprint: 'remote:empty|uid:cloud-user-1',
            ),
            currentMode: const DataModeState(
              dataMode: DataMode.localOnly,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          );

      expect(result.status, CloudActivationExecutionStatus.blocked);
      expect(
        result.blockReason,
        CloudActivationExecutionBlockReason.migrationExecutionNotImplemented,
      );
      expect(result.message, contains('Preflight migrateLocalToCloud прошёл'));
      expect(readinessService.callCount, 1);
    },
  );
}
