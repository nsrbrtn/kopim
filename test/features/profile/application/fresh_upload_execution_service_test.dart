import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/cloud_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_snapshot_builder.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_readiness_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_execution_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_runtime_guard.dart';
import 'package:kopim/features/profile/application/fresh_upload_execution_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_local_ownership_conversion_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_remote_verification_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_upload_service.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/data/cloud_metadata_repository.dart';
import 'package:kopim/features/profile/data/fresh_upload_finalization_repository.dart';
import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/cloud_activation_state.dart';
import 'package:kopim/features/profile/domain/entities/cloud_metadata.dart';
import 'package:kopim/features/profile/domain/entities/fresh_upload_finalization_marker.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

class _FakeLoggerService extends LoggerService {
  @override
  void logInfo(String message) {}

  @override
  void logWarning(String message) {}

  @override
  void logError(String message, [dynamic error]) {}
}

class _FakeMetadataRepository implements CloudMetadataRepository {
  _FakeMetadataRepository(this.metadata);

  CloudMetadata metadata;
  int startCount = 0;
  int completeCount = 0;

  @override
  Future<CloudMetadata?> getMetadata(String uid) async => metadata;

  @override
  Future<void> setCloudDataState(String uid, CloudDataState state) async {
    metadata = CloudMetadata(
      cloudDataState: state,
      freshUploadSessionId: metadata.freshUploadSessionId,
      updatedAt: DateTime.utc(2024, 1, 1),
    );
  }

  @override
  Future<void> updateMetadata(String uid, CloudMetadata metadata) async {
    this.metadata = metadata;
  }

  @override
  Future<CloudMetadata> startFreshUpload({
    required String uid,
    required String uploadSessionId,
  }) async {
    startCount += 1;
    if (metadata.cloudDataState != CloudDataState.deleted) {
      throw const CloudMetadataTransitionException(
        CloudMetadataTransitionFailureReason.stateMismatch,
        'not deleted',
      );
    }
    metadata = CloudMetadata(
      cloudDataState: CloudDataState.freshUploadInProgress,
      freshUploadSessionId: uploadSessionId,
      updatedAt: DateTime.utc(2024, 1, 1, 0, 1),
    );
    return metadata;
  }

  @override
  Future<CloudMetadata> completeFreshUpload({
    required String uid,
    required String uploadSessionId,
  }) async {
    completeCount += 1;
    if (metadata.cloudDataState != CloudDataState.freshUploadInProgress) {
      throw const CloudMetadataTransitionException(
        CloudMetadataTransitionFailureReason.stateMismatch,
        'not in progress',
      );
    }
    metadata = CloudMetadata(
      cloudDataState: CloudDataState.active,
      freshUploadSessionId: uploadSessionId,
      updatedAt: DateTime.utc(2024, 1, 1, 0, 2),
    );
    return metadata;
  }
}

class _FakeFinalizationRepository implements FreshUploadFinalizationRepository {
  FreshUploadFinalizationMarker? marker;
  int saveCount = 0;

  @override
  Future<void> clearMarkerForUid(String uid) async {
    marker = null;
  }

  @override
  Future<FreshUploadFinalizationMarker?> getMarkerForUid(String uid) async {
    return marker?.uid == uid ? marker : null;
  }

  @override
  Future<void> saveCompleted({
    required String uid,
    required String uploadSessionId,
    required DateTime remoteStateConfirmedAt,
    required DateTime localFinalizationCompletedAt,
  }) async {
    saveCount += 1;
    marker = FreshUploadFinalizationMarker(
      uid: uid,
      uploadSessionId: uploadSessionId,
      remoteStateConfirmedAt: remoteStateConfirmedAt,
      localFinalizationCompletedAt: localFinalizationCompletedAt,
      version: 1,
    );
  }
}

class _FakeActivationStateRepository implements CloudActivationStateRepository {
  CloudActivationState? state;

  @override
  Future<void> clearStateForUid(String uid) async {}

  @override
  Future<CloudActivationState?> getStateForUid(String uid) async => state;

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
      activatedAt: DateTime.utc(2024, 1, 1),
      localFingerprint: localFingerprint,
      remoteFingerprint: remoteFingerprint,
      version: 1,
    );
  }
}

class _FakeMigrationStateRepository
    implements LocalToCloudMigrationStateRepository {
  LocalToCloudMigrationState? state;

  @override
  Future<void> clearStateForUid(String uid) async {
    state = null;
  }

  @override
  Future<LocalToCloudMigrationState?> getStateForUid(String uid) async {
    return state?.uid == uid ? state : null;
  }

  @override
  Future<void> saveState(LocalToCloudMigrationState state) async {
    this.state = state;
  }
}

class _FakeEntitlementRepository implements CloudEntitlementRepository {
  _FakeEntitlementRepository(this.state);

  CloudEntitlementState state;

  @override
  Future<CloudEntitlementResult> activateKey(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearEntitlement() async {}

  @override
  Future<CloudEntitlementState> getCachedState() async => state;

  @override
  Future<CloudEntitlementState> refreshFromCurrentToken() async => state;
}

class _FakeLocalSnapshotSummaryService implements LocalSnapshotSummaryService {
  @override
  Future<LocalSnapshotSummary> summarize({
    bool includeActivationGuard = true,
  }) async {
    return const LocalSnapshotSummary(
      state: LocalSnapshotState.hasUserData,
      hasUserData: true,
      hasSystemData: true,
      pendingOutboxCount: 0,
      fingerprint: 'local:fresh',
    );
  }
}

class _FakeCloudSnapshotSummaryService implements CloudSnapshotSummaryService {
  @override
  Future<CloudSnapshotSummary> summarize(String uid) async {
    return const CloudSnapshotSummary(
      state: RemoteSnapshotState.hasUserData,
      hasUserData: true,
      hasMetadata: true,
      hasTombstonesOnly: false,
      fingerprint: 'remote:fresh',
    );
  }
}

class _FakeReadinessService implements LocalToCloudMigrationReadinessService {
  int callCount = 0;

  @override
  Future<LocalToCloudMigrationPreflightResult> captureReadiness({
    String? uid,
  }) async {
    callCount += 1;
    return const LocalToCloudMigrationPreflightResult.ready(
      localSummary: LocalSnapshotSummary(
        state: LocalSnapshotState.hasUserData,
        hasUserData: true,
        hasSystemData: true,
        pendingOutboxCount: 0,
        fingerprint: 'local:fresh',
      ),
      inventorySnapshot: LocalToCloudMigrationInventorySnapshot(
        candidateFamilyKeys: <String>{},
        rowsByFamily: <String, List<LocalToCloudMigrationRow>>{},
      ),
      readinessResult: LocalToCloudMigrationReadinessResult.ready(),
    );
  }
}

class _FakeUploadService implements LocalToCloudMigrationUploadService {
  int callCount = 0;
  LocalToCloudMigrationUploadResult result =
      const LocalToCloudMigrationUploadResult.succeeded(
        uploadedRowCountsByFamily: <String, int>{},
      );

  @override
  Future<LocalToCloudMigrationUploadResult> uploadPreparedMigration({
    required String uid,
  }) async {
    callCount += 1;
    return result;
  }
}

class _FakeRemoteVerificationService
    implements LocalToCloudMigrationRemoteVerificationService {
  int callCount = 0;
  LocalToCloudMigrationRemoteVerificationResult result =
      const LocalToCloudMigrationRemoteVerificationResult.succeeded(
        verifiedRowCountsByFamily: <String, int>{},
      );

  @override
  Future<LocalToCloudMigrationRemoteVerificationResult> verifyUploadedGraph({
    required String uid,
  }) async {
    callCount += 1;
    return result;
  }
}

class _FakeLocalOwnershipConversionService
    implements LocalToCloudMigrationLocalOwnershipConversionService {
  int callCount = 0;
  LocalToCloudMigrationLocalOwnershipConversionResult result =
      const LocalToCloudMigrationLocalOwnershipConversionResult.succeeded(
        convertedRowCount: 0,
      );

  @override
  Future<LocalToCloudMigrationLocalOwnershipConversionResult>
  convertVerifiedMigration({required String uid}) async {
    callCount += 1;
    return result;
  }
}

FreshUploadExecutionService _buildService({
  required _FakeMetadataRepository metadataRepository,
  required _FakeFinalizationRepository finalizationRepository,
  required _FakeActivationStateRepository activationStateRepository,
  required _FakeMigrationStateRepository migrationStateRepository,
  required _FakeEntitlementRepository entitlementRepository,
  required _FakeReadinessService readinessService,
  required _FakeUploadService uploadService,
  required _FakeRemoteVerificationService remoteVerificationService,
  required _FakeLocalOwnershipConversionService localOwnershipConversionService,
}) {
  return FreshUploadExecutionService(
    metadataRepository: metadataRepository,
    finalizationRepository: finalizationRepository,
    activationStateRepository: activationStateRepository,
    migrationStateRepository: migrationStateRepository,
    entitlementRepository: entitlementRepository,
    localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(),
    cloudSnapshotSummaryService: _FakeCloudSnapshotSummaryService(),
    readinessService: readinessService,
    uploadService: uploadService,
    remoteVerificationService: remoteVerificationService,
    localOwnershipConversionService: localOwnershipConversionService,
    runtimeGuard: CloudActivationRuntimeGuard(),
    logger: _FakeLoggerService(),
  );
}

void main() {
  const AuthUser user = AuthUser(
    uid: 'cloud-user-1',
    email: 'user@example.com',
    isAnonymous: false,
  );

  setUp(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
  });

  test(
    'runs deleted Fresh Upload through active and local finalization',
    () async {
      final _FakeMetadataRepository metadataRepository =
          _FakeMetadataRepository(
            CloudMetadata(
              cloudDataState: CloudDataState.deleted,
              updatedAt: DateTime.utc(2024, 1, 1),
            ),
          );
      final _FakeFinalizationRepository finalizationRepository =
          _FakeFinalizationRepository();
      final _FakeActivationStateRepository activationStateRepository =
          _FakeActivationStateRepository();
      final _FakeMigrationStateRepository migrationStateRepository =
          _FakeMigrationStateRepository();
      final _FakeReadinessService readinessService = _FakeReadinessService();
      final _FakeUploadService uploadService = _FakeUploadService();
      final _FakeRemoteVerificationService remoteVerificationService =
          _FakeRemoteVerificationService();
      final _FakeLocalOwnershipConversionService
      localOwnershipConversionService = _FakeLocalOwnershipConversionService();
      final FreshUploadExecutionService service = _buildService(
        metadataRepository: metadataRepository,
        finalizationRepository: finalizationRepository,
        activationStateRepository: activationStateRepository,
        migrationStateRepository: migrationStateRepository,
        entitlementRepository: _FakeEntitlementRepository(
          CloudEntitlementState.active,
        ),
        readinessService: readinessService,
        uploadService: uploadService,
        remoteVerificationService: remoteVerificationService,
        localOwnershipConversionService: localOwnershipConversionService,
      );

      final CloudActivationExecutionResult result = await service
          .confirmFreshUploadFromLocal(
            currentUser: user,
            currentMode: const DataModeState(
              dataMode: DataMode.localOnly,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
              cloudDataState: CloudDataState.deleted,
              requiresFreshCloudUpload: true,
            ),
            refreshRuntimeMode: () async => const DataModeState(
              dataMode: DataMode.cloudEnabled,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
              cloudDataState: CloudDataState.active,
            ),
          );

      expect(result.status, CloudActivationExecutionStatus.succeeded);
      expect(metadataRepository.startCount, 1);
      expect(metadataRepository.completeCount, 1);
      expect(readinessService.callCount, 1);
      expect(uploadService.callCount, 1);
      expect(remoteVerificationService.callCount, 1);
      expect(localOwnershipConversionService.callCount, 1);
      expect(finalizationRepository.marker?.uid, user.uid);
      expect(activationStateRepository.state?.scenario, 'freshUploadFromLocal');
    },
  );

  test('active remote state retries local finalization only', () async {
    final _FakeMetadataRepository metadataRepository = _FakeMetadataRepository(
      CloudMetadata(
        cloudDataState: CloudDataState.active,
        freshUploadSessionId: 'fresh-session-1',
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
    final _FakeReadinessService readinessService = _FakeReadinessService();
    final _FakeUploadService uploadService = _FakeUploadService();
    final _FakeRemoteVerificationService remoteVerificationService =
        _FakeRemoteVerificationService();
    final _FakeLocalOwnershipConversionService localOwnershipConversionService =
        _FakeLocalOwnershipConversionService();
    final FreshUploadExecutionService service = _buildService(
      metadataRepository: metadataRepository,
      finalizationRepository: _FakeFinalizationRepository(),
      activationStateRepository: _FakeActivationStateRepository(),
      migrationStateRepository: _FakeMigrationStateRepository(),
      entitlementRepository: _FakeEntitlementRepository(
        CloudEntitlementState.active,
      ),
      readinessService: readinessService,
      uploadService: uploadService,
      remoteVerificationService: remoteVerificationService,
      localOwnershipConversionService: localOwnershipConversionService,
    );

    final CloudActivationExecutionResult result = await service
        .confirmFreshUploadFromLocal(
          currentUser: user,
          currentMode: const DataModeState(
            dataMode: DataMode.localOnly,
            entitlementState: CloudEntitlementState.active,
            migrationDecision: MigrationDecision.none,
            cloudDataState: CloudDataState.active,
            requiresFreshUploadFinalization: true,
          ),
          refreshRuntimeMode: () async => const DataModeState(
            dataMode: DataMode.cloudEnabled,
            entitlementState: CloudEntitlementState.active,
            migrationDecision: MigrationDecision.none,
            cloudDataState: CloudDataState.active,
          ),
        );

    expect(result.status, CloudActivationExecutionStatus.succeeded);
    expect(metadataRepository.startCount, 0);
    expect(metadataRepository.completeCount, 0);
    expect(readinessService.callCount, 0);
    expect(uploadService.callCount, 0);
    expect(remoteVerificationService.callCount, 0);
    expect(localOwnershipConversionService.callCount, 1);
  });

  test('blocks before remote writes when entitlement is not active', () async {
    final _FakeMetadataRepository metadataRepository = _FakeMetadataRepository(
      CloudMetadata(
        cloudDataState: CloudDataState.deleted,
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
    final FreshUploadExecutionService service = _buildService(
      metadataRepository: metadataRepository,
      finalizationRepository: _FakeFinalizationRepository(),
      activationStateRepository: _FakeActivationStateRepository(),
      migrationStateRepository: _FakeMigrationStateRepository(),
      entitlementRepository: _FakeEntitlementRepository(
        CloudEntitlementState.expired,
      ),
      readinessService: _FakeReadinessService(),
      uploadService: _FakeUploadService(),
      remoteVerificationService: _FakeRemoteVerificationService(),
      localOwnershipConversionService: _FakeLocalOwnershipConversionService(),
    );

    final CloudActivationExecutionResult result = await service
        .confirmFreshUploadFromLocal(
          currentUser: user,
          currentMode: const DataModeState(
            dataMode: DataMode.localOnly,
            entitlementState: CloudEntitlementState.expired,
            migrationDecision: MigrationDecision.none,
            cloudDataState: CloudDataState.deleted,
          ),
          refreshRuntimeMode: () async => throw StateError('not called'),
        );

    expect(result.status, CloudActivationExecutionStatus.blocked);
    expect(
      result.blockReason,
      CloudActivationExecutionBlockReason.entitlementRequired,
    );
    expect(metadataRepository.startCount, 0);
  });
}
