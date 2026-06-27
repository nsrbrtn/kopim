import 'package:riverpod/riverpod.dart';

import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/cloud_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_snapshot_builder.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_readiness_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_execution_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_runtime_guard.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_local_ownership_conversion_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_remote_verification_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_upload_service.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/data/cloud_metadata_repository.dart';
import 'package:kopim/features/profile/data/fresh_upload_finalization_repository.dart';
import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/cloud_metadata.dart';
import 'package:kopim/features/profile/domain/entities/fresh_upload_finalization_marker.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

class FreshUploadExecutionService {
  const FreshUploadExecutionService({
    required CloudMetadataRepository metadataRepository,
    required FreshUploadFinalizationRepository finalizationRepository,
    required CloudActivationStateRepository activationStateRepository,
    required LocalToCloudMigrationStateRepository migrationStateRepository,
    required CloudEntitlementRepository entitlementRepository,
    required LocalSnapshotSummaryService localSnapshotSummaryService,
    required CloudSnapshotSummaryService cloudSnapshotSummaryService,
    required LocalToCloudMigrationReadinessService readinessService,
    required LocalToCloudMigrationUploadService uploadService,
    required LocalToCloudMigrationRemoteVerificationService
    remoteVerificationService,
    required LocalToCloudMigrationLocalOwnershipConversionService
    localOwnershipConversionService,
    required CloudActivationRuntimeGuard runtimeGuard,
    required LoggerService logger,
  }) : _metadataRepository = metadataRepository,
       _finalizationRepository = finalizationRepository,
       _activationStateRepository = activationStateRepository,
       _migrationStateRepository = migrationStateRepository,
       _entitlementRepository = entitlementRepository,
       _localSnapshotSummaryService = localSnapshotSummaryService,
       _cloudSnapshotSummaryService = cloudSnapshotSummaryService,
       _readinessService = readinessService,
       _uploadService = uploadService,
       _remoteVerificationService = remoteVerificationService,
       _localOwnershipConversionService = localOwnershipConversionService,
       _runtimeGuard = runtimeGuard,
       _logger = logger;

  final CloudMetadataRepository _metadataRepository;
  final FreshUploadFinalizationRepository _finalizationRepository;
  final CloudActivationStateRepository _activationStateRepository;
  final LocalToCloudMigrationStateRepository _migrationStateRepository;
  final CloudEntitlementRepository _entitlementRepository;
  final LocalSnapshotSummaryService _localSnapshotSummaryService;
  final CloudSnapshotSummaryService _cloudSnapshotSummaryService;
  final LocalToCloudMigrationReadinessService _readinessService;
  final LocalToCloudMigrationUploadService _uploadService;
  final LocalToCloudMigrationRemoteVerificationService
  _remoteVerificationService;
  final LocalToCloudMigrationLocalOwnershipConversionService
  _localOwnershipConversionService;
  final CloudActivationRuntimeGuard _runtimeGuard;
  final LoggerService _logger;

  Future<CloudActivationExecutionResult> confirmFreshUploadFromLocal({
    required AuthUser? currentUser,
    required DataModeState? currentMode,
    required Future<DataModeState> Function() refreshRuntimeMode,
  }) async {
    if (!AppRuntimeConfig.isCloudCapableDistribution) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.capabilitiesDisabled,
      );
    }
    if (currentUser == null || currentUser.isAnonymous) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.signInRequired,
      );
    }
    if (currentMode?.dataMode == DataMode.cloudEnabled) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.alreadyCloudEnabled,
      );
    }
    final CloudEntitlementState entitlement = await _entitlementRepository
        .getCachedState();
    if (entitlement != CloudEntitlementState.active) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.entitlementRequired,
      );
    }
    if (!_runtimeGuard.tryAcquire()) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.activationInProgress,
      );
    }

    final String uid = currentUser.uid;
    try {
      final CloudMetadata? metadata = await _metadataRepository.getMetadata(
        uid,
      );
      if (metadata == null) {
        return const CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.remoteMetadataPresent,
          message:
              'Fresh Upload требует удалённую metadata в состоянии deleted.',
        );
      }

      if (metadata.cloudDataState == CloudDataState.active) {
        return _finalizeAlreadyActive(
          uid: uid,
          metadata: metadata,
          refreshRuntimeMode: refreshRuntimeMode,
        );
      }

      if (metadata.cloudDataState != CloudDataState.deleted &&
          metadata.cloudDataState != CloudDataState.freshUploadInProgress) {
        return const CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.remoteNotEmpty,
          message:
              'Fresh Upload допускается только из deleted или freshUploadInProgress.',
        );
      }

      final String uploadSessionId =
          metadata.freshUploadSessionId ?? _newUploadSessionId();
      await _ensurePreparedState(uid: uid, uploadSessionId: uploadSessionId);

      if (metadata.cloudDataState == CloudDataState.deleted) {
        await _metadataRepository.startFreshUpload(
          uid: uid,
          uploadSessionId: uploadSessionId,
        );
      }

      final CloudActivationExecutionResult? uploadBlock =
          await _runUploadAndVerification(uid);
      if (uploadBlock != null) {
        return uploadBlock;
      }

      final CloudMetadata activeMetadata = await _metadataRepository
          .completeFreshUpload(uid: uid, uploadSessionId: uploadSessionId);
      return _finalizeAlreadyActive(
        uid: uid,
        metadata: activeMetadata,
        refreshRuntimeMode: refreshRuntimeMode,
      );
    } on CloudMetadataTransitionException catch (error) {
      return _metadataTransitionResult(error);
    } catch (error) {
      _logger.logError('Fresh Upload execution failed for $uid: $error', error);
      return CloudActivationExecutionResult.failed(message: error.toString());
    } finally {
      _runtimeGuard.release();
    }
  }

  Future<CloudActivationExecutionResult> _finalizeAlreadyActive({
    required String uid,
    required CloudMetadata metadata,
    required Future<DataModeState> Function() refreshRuntimeMode,
  }) async {
    final String? uploadSessionId = metadata.freshUploadSessionId;
    if (uploadSessionId == null || uploadSessionId.trim().isEmpty) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteMetadataPresent,
        message: 'Remote metadata active не содержит Fresh Upload session.',
      );
    }

    final FreshUploadFinalizationMarker? marker = await _finalizationRepository
        .getMarkerForUid(uid);
    if (marker?.uploadSessionId != uploadSessionId) {
      final LocalToCloudMigrationLocalOwnershipConversionResult convertResult =
          await _localOwnershipConversionService.convertVerifiedMigration(
            uid: uid,
          );
      if (convertResult.status !=
          LocalToCloudMigrationLocalOwnershipConversionStatus.succeeded) {
        return CloudActivationExecutionResult.blocked(
          _mapConversionBlock(convertResult.blockReason),
          message: convertResult.message,
        );
      }
      final DateTime now = DateTime.now().toUtc();
      await _finalizationRepository.saveCompleted(
        uid: uid,
        uploadSessionId: uploadSessionId,
        remoteStateConfirmedAt: metadata.updatedAt,
        localFinalizationCompletedAt: now,
      );
    }

    final LocalSnapshotSummary localSummary = await _localSnapshotSummaryService
        .summarize(includeActivationGuard: false);
    final CloudSnapshotSummary remoteSummary =
        await _cloudSnapshotSummaryService.summarize(uid);
    await _activationStateRepository.saveEnabledState(
      uid: uid,
      scenario: 'freshUploadFromLocal',
      localFingerprint: localSummary.fingerprint,
      remoteFingerprint: remoteSummary.fingerprint,
    );

    final DataModeState nextState = await refreshRuntimeMode();
    if (nextState.dataMode != DataMode.cloudEnabled) {
      return const CloudActivationExecutionResult.failed(
        message: 'Fresh Upload завершён, но runtime cloudEnabled не включился.',
      );
    }
    return const CloudActivationExecutionResult.succeededWithMessage(
      'Fresh Upload завершён: облачный граф проверен, локальное состояние финализировано, синхронизация включена.',
    );
  }

  Future<void> _ensurePreparedState({
    required String uid,
    required String uploadSessionId,
  }) async {
    final LocalToCloudMigrationState? existingState =
        await _migrationStateRepository.getStateForUid(uid);
    if (existingState != null) {
      return;
    }

    final LocalToCloudMigrationPreflightResult preflight =
        await _readinessService.captureReadiness(uid: uid);
    if (!preflight.isReady) {
      throw StateError(
        preflight.readinessResult?.issues.isNotEmpty == true
            ? preflight.readinessResult!.issues.first.message
            : 'Fresh Upload readiness is blocked.',
      );
    }
    final LocalSnapshotSummary localSummary = preflight.localSummary!;
    final LocalToCloudMigrationInventorySnapshot inventorySnapshot =
        preflight.inventorySnapshot!;
    final DateTime now = DateTime.now().toUtc();
    final List<LocalToCloudMigrationPlanRow>
    rows = <LocalToCloudMigrationPlanRow>[
      for (final MapEntry<String, List<LocalToCloudMigrationRow>> familyEntry
          in inventorySnapshot.rowsByFamily.entries)
        for (final LocalToCloudMigrationRow row in familyEntry.value)
          LocalToCloudMigrationPlanRow(
            familyKey: familyEntry.key,
            localRowId: row.localRowId,
            documentId: row.reusedDocumentId,
          ),
    ];
    await _migrationStateRepository.saveState(
      LocalToCloudMigrationState(
        uid: uid,
        stage: LocalToCloudMigrationStage.backupCreated,
        createdAt: now,
        updatedAt: now,
        plan: LocalToCloudMigrationPlan(
          migrationId: uploadSessionId,
          createdAt: now,
          localFingerprint: localSummary.fingerprint,
          remoteFingerprint: 'fresh-upload:${CloudDataState.deleted.name}',
          candidateFamilyKeys: inventorySnapshot.candidateFamilyKeys.toList()
            ..sort(),
          rows: List<LocalToCloudMigrationPlanRow>.unmodifiable(rows),
        ),
        version: 1,
        localFingerprintBeforeUpload: localSummary.fingerprint,
      ),
    );
  }

  Future<CloudActivationExecutionResult?> _runUploadAndVerification(
    String uid,
  ) async {
    final LocalToCloudMigrationUploadResult uploadResult = await _uploadService
        .uploadPreparedMigration(uid: uid);
    if (uploadResult.status != LocalToCloudMigrationUploadStatus.succeeded) {
      return CloudActivationExecutionResult.blocked(
        uploadResult.status == LocalToCloudMigrationUploadStatus.blocked
            ? CloudActivationExecutionBlockReason.migrationPayloadMismatch
            : CloudActivationExecutionBlockReason.migrationNetworkRetryable,
        message: uploadResult.message,
      );
    }

    final LocalToCloudMigrationRemoteVerificationResult verifyResult =
        await _remoteVerificationService.verifyUploadedGraph(uid: uid);
    if (verifyResult.status !=
        LocalToCloudMigrationRemoteVerificationStatus.succeeded) {
      return CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.migrationPayloadMismatch,
        message: verifyResult.message,
      );
    }
    return null;
  }

  CloudActivationExecutionResult _metadataTransitionResult(
    CloudMetadataTransitionException error,
  ) {
    final CloudActivationExecutionBlockReason reason = switch (error.reason) {
      CloudMetadataTransitionFailureReason.permissionDenied =>
        CloudActivationExecutionBlockReason.remotePermissionDenied,
      CloudMetadataTransitionFailureReason.entitlementDenied =>
        CloudActivationExecutionBlockReason.entitlementRequired,
      CloudMetadataTransitionFailureReason.networkFailure =>
        CloudActivationExecutionBlockReason.remoteUnavailable,
      CloudMetadataTransitionFailureReason.stateMismatch ||
      CloudMetadataTransitionFailureReason.readbackMismatch =>
        CloudActivationExecutionBlockReason.remoteNotEmpty,
    };
    return CloudActivationExecutionResult.blocked(
      reason,
      message: error.message,
    );
  }

  CloudActivationExecutionBlockReason _mapConversionBlock(
    LocalToCloudMigrationLocalOwnershipConversionBlockReason? reason,
  ) {
    return switch (reason) {
      LocalToCloudMigrationLocalOwnershipConversionBlockReason
          .missingPreparedState =>
        CloudActivationExecutionBlockReason.pendingIntentMissing,
      LocalToCloudMigrationLocalOwnershipConversionBlockReason
          .invalidPreparedState =>
        CloudActivationExecutionBlockReason.migrationReadinessBlocked,
      LocalToCloudMigrationLocalOwnershipConversionBlockReason
          .integrityViolation =>
        CloudActivationExecutionBlockReason.migrationConversionIntegrityFailed,
      null => CloudActivationExecutionBlockReason.migrationUnknownFailure,
    };
  }

  String _newUploadSessionId() {
    return 'fresh-upload-${DateTime.now().toUtc().microsecondsSinceEpoch}';
  }
}

final Provider<FreshUploadExecutionService>
freshUploadExecutionServiceProvider = Provider<FreshUploadExecutionService>((
  Ref ref,
) {
  return FreshUploadExecutionService(
    metadataRepository: ref.watch(cloudMetadataRepositoryProvider),
    finalizationRepository: ref.watch(
      freshUploadFinalizationRepositoryProvider,
    ),
    activationStateRepository: ref.watch(
      cloudActivationStateRepositoryProvider,
    ),
    migrationStateRepository: ref.watch(
      localToCloudMigrationStateRepositoryProvider,
    ),
    entitlementRepository: ref.watch(cloudEntitlementRepositoryProvider),
    localSnapshotSummaryService: ref.watch(localSnapshotSummaryServiceProvider),
    cloudSnapshotSummaryService: ref.watch(cloudSnapshotSummaryServiceProvider),
    readinessService: ref.watch(localToCloudMigrationReadinessServiceProvider),
    uploadService: ref.watch(localToCloudMigrationUploadServiceProvider),
    remoteVerificationService: ref.watch(
      localToCloudMigrationRemoteVerificationServiceProvider,
    ),
    localOwnershipConversionService: ref.watch(
      localToCloudMigrationLocalOwnershipConversionServiceProvider,
    ),
    runtimeGuard: ref.watch(cloudActivationRuntimeGuardProvider),
    logger: ref.watch(loggerServiceProvider),
  );
});
