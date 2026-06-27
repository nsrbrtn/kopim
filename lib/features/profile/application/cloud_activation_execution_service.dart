import 'package:riverpod/riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_upload_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_remote_verification_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_local_ownership_conversion_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/cloud_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_snapshot_builder.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_readiness_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_runtime_guard.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';
import 'package:kopim/features/profile/domain/repositories/user_account_cleanup_repository.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_integrity_service.dart';
import 'package:kopim/features/settings/domain/use_cases/export_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';

enum CloudActivationExecutionStatus { idle, succeeded, blocked, failed }

enum CloudActivationExecutionBlockReason {
  capabilitiesDisabled,
  signInRequired,
  entitlementRequired,
  activationInProgress,
  pendingIntentMissing,
  invalidPendingIntent,
  localNotEmpty,
  remoteNotEmpty,
  remoteMetadataPresent,
  remoteUnavailable,
  remotePermissionDenied,
  staleReadiness,
  alreadyCloudEnabled,
  backupExportFailed,
  localResetFailed,
  migrationReadinessBlocked,
  migrationExecutionNotImplemented,
  runtimeTransitionFailed,
  migrationNetworkRetryable,
  migrationRemoteOccupied,
  migrationPayloadMismatch,
  migrationUidChanged,
  migrationLocalDataChanged,
  migrationConversionIntegrityFailed,
  migrationUnknownFailure,
}

class CloudActivationExecutionResult {
  const CloudActivationExecutionResult._({
    required this.status,
    this.blockReason,
    this.message,
  });

  const CloudActivationExecutionResult.idle()
    : this._(status: CloudActivationExecutionStatus.idle);

  const CloudActivationExecutionResult.succeeded()
    : this._(status: CloudActivationExecutionStatus.succeeded);

  const CloudActivationExecutionResult.succeededWithMessage(String message)
    : this._(
        status: CloudActivationExecutionStatus.succeeded,
        message: message,
      );

  const CloudActivationExecutionResult.blocked(
    CloudActivationExecutionBlockReason reason, {
    String? message,
  }) : this._(
         status: CloudActivationExecutionStatus.blocked,
         blockReason: reason,
         message: message,
       );

  const CloudActivationExecutionResult.failed({String? message})
    : this._(
        status: CloudActivationExecutionStatus.failed,
        blockReason:
            CloudActivationExecutionBlockReason.runtimeTransitionFailed,
        message: message,
      );

  const CloudActivationExecutionResult.failedFor(
    CloudActivationExecutionBlockReason reason, {
    String? message,
  }) : this._(
         status: CloudActivationExecutionStatus.failed,
         blockReason: reason,
         message: message,
       );

  final CloudActivationExecutionStatus status;
  final CloudActivationExecutionBlockReason? blockReason;
  final String? message;
}

class CloudActivationExecutionService {
  const CloudActivationExecutionService({
    required FirebaseFirestore firestore,
    required LocalToCloudMigrationUploadService uploadService,
    required LocalToCloudMigrationRemoteVerificationService
    remoteVerificationService,
    required LocalToCloudMigrationLocalOwnershipConversionService
    localOwnershipConversionService,
    required CloudActivationStateRepository activationStateRepository,
    required LocalToCloudMigrationStateRepository migrationStateRepository,
    required CloudEntitlementRepository entitlementRepository,
    required LocalSnapshotSummaryService localSnapshotSummaryService,
    required CloudSnapshotSummaryService cloudSnapshotSummaryService,
    required LocalToCloudMigrationReadinessService
    localToCloudMigrationReadinessService,
    required PrepareExportBundleUseCase prepareExportBundleUseCase,
    required ExportUserDataUseCase exportUserDataUseCase,
    required UserAccountCleanupRepository userAccountCleanupRepository,
    required CloudActivationRuntimeGuard runtimeGuard,
    required LoggerService logger,
  }) : _firestore = firestore,
       _uploadService = uploadService,
       _remoteVerificationService = remoteVerificationService,
       _localOwnershipConversionService = localOwnershipConversionService,
       _activationStateRepository = activationStateRepository,
       _migrationStateRepository = migrationStateRepository,
       _entitlementRepository = entitlementRepository,
       _localSnapshotSummaryService = localSnapshotSummaryService,
       _cloudSnapshotSummaryService = cloudSnapshotSummaryService,
       _localToCloudMigrationReadinessService =
           localToCloudMigrationReadinessService,
       _prepareExportBundleUseCase = prepareExportBundleUseCase,
       _exportUserDataUseCase = exportUserDataUseCase,
       _userAccountCleanupRepository = userAccountCleanupRepository,
       _runtimeGuard = runtimeGuard,
       _logger = logger;

  final FirebaseFirestore _firestore;
  final LocalToCloudMigrationUploadService _uploadService;
  final LocalToCloudMigrationRemoteVerificationService
  _remoteVerificationService;
  final LocalToCloudMigrationLocalOwnershipConversionService
  _localOwnershipConversionService;
  final CloudActivationStateRepository _activationStateRepository;
  final LocalToCloudMigrationStateRepository _migrationStateRepository;
  final CloudEntitlementRepository _entitlementRepository;
  final LocalSnapshotSummaryService _localSnapshotSummaryService;
  final CloudSnapshotSummaryService _cloudSnapshotSummaryService;
  final LocalToCloudMigrationReadinessService
  _localToCloudMigrationReadinessService;
  final PrepareExportBundleUseCase _prepareExportBundleUseCase;
  final ExportUserDataUseCase _exportUserDataUseCase;
  final UserAccountCleanupRepository _userAccountCleanupRepository;
  final CloudActivationRuntimeGuard _runtimeGuard;
  final LoggerService _logger;

  Future<CloudActivationExecutionResult> confirmEnableCloudSync({
    required AuthUser? currentUser,
    required CloudActivationIntentState intentState,
    required DataModeState? currentMode,
    required Future<DataModeState> Function() refreshRuntimeMode,
  }) async {
    final CloudActivationExecutionResult? commonBlock =
        await _validateCommonPreconditions(
          currentUser: currentUser,
          intentState: intentState,
          currentMode: currentMode,
          expectedChoice: CloudActivationChoice.enableCloudSync,
        );
    if (commonBlock != null) {
      return commonBlock;
    }

    final LocalSnapshotSummary localSummary = await _localSnapshotSummaryService
        .summarize();
    final CloudSnapshotSummary remoteSummary =
        await _cloudSnapshotSummaryService.summarize(currentUser!.uid);
    final CloudActivationExecutionResult? precheckBlock = _validateSnapshotPair(
      localSummary: localSummary,
      remoteSummary: remoteSummary,
      intentState: intentState,
    );
    if (precheckBlock != null) {
      return precheckBlock;
    }

    if (!_runtimeGuard.tryAcquire()) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.activationInProgress,
      );
    }

    try {
      final LocalSnapshotSummary guardedLocalSummary =
          await _localSnapshotSummaryService.summarize(
            includeActivationGuard: false,
          );
      final CloudSnapshotSummary guardedRemoteSummary =
          await _cloudSnapshotSummaryService.summarize(currentUser.uid);

      final CloudActivationExecutionResult? guardedBlock =
          _validateSnapshotPair(
            localSummary: guardedLocalSummary,
            remoteSummary: guardedRemoteSummary,
            intentState: intentState,
          );
      if (guardedBlock != null) {
        return guardedBlock;
      }

      await _activationStateRepository.saveEnabledState(
        uid: currentUser.uid,
        scenario: CloudActivationChoice.enableCloudSync.name,
        localFingerprint: guardedLocalSummary.fingerprint,
        remoteFingerprint: guardedRemoteSummary.fingerprint,
      );

      final DataModeState nextState = await refreshRuntimeMode();
      if (nextState.dataMode != DataMode.cloudEnabled) {
        _logger.logWarning(
          'Cloud activation flag persisted for ${currentUser.uid}, but runtime mode stayed ${nextState.dataMode.name}.',
        );
        return const CloudActivationExecutionResult.failed(
          message:
              'Не удалось безопасно перевести приложение в облачный режим.',
        );
      }

      return const CloudActivationExecutionResult.succeeded();
    } catch (error) {
      _logger.logError(
        'Cloud activation execution failed for ${currentUser.uid}: $error',
        error,
      );
      return CloudActivationExecutionResult.failed(message: error.toString());
    } finally {
      _runtimeGuard.release();
    }
  }

  Future<CloudActivationExecutionResult> confirmReplaceLocalWithCloud({
    required AuthUser? currentUser,
    required CloudActivationIntentState intentState,
    required DataModeState? currentMode,
    required Future<DataModeState> Function() refreshRuntimeMode,
  }) async {
    final CloudActivationExecutionResult? commonBlock =
        await _validateCommonPreconditions(
          currentUser: currentUser,
          intentState: intentState,
          currentMode: currentMode,
          expectedChoice: CloudActivationChoice.replaceLocalWithCloud,
        );
    if (commonBlock != null) {
      return commonBlock;
    }

    final LocalSnapshotSummary localSummary = await _localSnapshotSummaryService
        .summarize();
    final CloudSnapshotSummary remoteSummary =
        await _cloudSnapshotSummaryService.summarize(currentUser!.uid);
    final CloudActivationExecutionResult? precheckBlock =
        _validateReplaceLocalWithCloudSnapshotPair(
          localSummary: localSummary,
          remoteSummary: remoteSummary,
          intentState: intentState,
        );
    if (precheckBlock != null) {
      return precheckBlock;
    }

    if (!_runtimeGuard.tryAcquire()) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.activationInProgress,
      );
    }

    try {
      final LocalSnapshotSummary guardedLocalSummary =
          await _localSnapshotSummaryService.summarize(
            includeActivationGuard: false,
          );
      final CloudSnapshotSummary guardedRemoteSummary =
          await _cloudSnapshotSummaryService.summarize(currentUser.uid);

      final CloudActivationExecutionResult? guardedBlock =
          _validateReplaceLocalWithCloudSnapshotPair(
            localSummary: guardedLocalSummary,
            remoteSummary: guardedRemoteSummary,
            intentState: intentState,
          );
      if (guardedBlock != null) {
        return guardedBlock;
      }

      await _activationStateRepository.saveEnabledState(
        uid: currentUser.uid,
        scenario: CloudActivationChoice.replaceLocalWithCloud.name,
        localFingerprint: guardedLocalSummary.fingerprint,
        remoteFingerprint: guardedRemoteSummary.fingerprint,
      );

      final DataModeState nextState = await refreshRuntimeMode();
      if (nextState.dataMode != DataMode.cloudEnabled) {
        _logger.logWarning(
          'Replace-local-with-cloud activation flag persisted for ${currentUser.uid}, but runtime mode stayed ${nextState.dataMode.name}.',
        );
        return const CloudActivationExecutionResult.failed(
          message:
              'Не удалось безопасно перевести приложение в облачный режим.',
        );
      }

      return const CloudActivationExecutionResult.succeeded();
    } catch (error) {
      _logger.logError(
        'Replace-local-with-cloud execution failed for ${currentUser.uid}: $error',
        error,
      );
      return CloudActivationExecutionResult.failed(message: error.toString());
    } finally {
      _runtimeGuard.release();
    }
  }

  Future<CloudActivationExecutionResult> confirmStartWithEmptyCloud({
    required AuthUser? currentUser,
    required CloudActivationIntentState intentState,
    required DataModeState? currentMode,
    required Future<DataModeState> Function() refreshRuntimeMode,
  }) async {
    final CloudActivationExecutionResult? commonBlock =
        await _validateCommonPreconditions(
          currentUser: currentUser,
          intentState: intentState,
          currentMode: currentMode,
          expectedChoice: CloudActivationChoice.startWithEmptyCloud,
        );
    if (commonBlock != null) {
      return commonBlock;
    }

    final LocalSnapshotSummary localSummary = await _localSnapshotSummaryService
        .summarize();
    final CloudSnapshotSummary remoteSummary =
        await _cloudSnapshotSummaryService.summarize(currentUser!.uid);
    final CloudActivationExecutionResult? precheckBlock =
        _validateStartWithEmptyCloudSnapshotPair(
          localSummary: localSummary,
          remoteSummary: remoteSummary,
          intentState: intentState,
        );
    if (precheckBlock != null) {
      return precheckBlock;
    }

    final ExportFileSaveResult exportResult = await _exportUserDataUseCase(
      const ExportUserDataParams(),
    );
    if (!exportResult.isSuccess) {
      return CloudActivationExecutionResult.failedFor(
        CloudActivationExecutionBlockReason.backupExportFailed,
        message:
            exportResult.errorMessage ??
            'Не удалось создать резервную копию локальных данных.',
      );
    }

    if (!_runtimeGuard.tryAcquire()) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.activationInProgress,
      );
    }

    try {
      final LocalSnapshotSummary guardedLocalSummary =
          await _localSnapshotSummaryService.summarize(
            includeActivationGuard: false,
          );
      final CloudSnapshotSummary guardedRemoteSummary =
          await _cloudSnapshotSummaryService.summarize(currentUser.uid);

      final CloudActivationExecutionResult? guardedBlock =
          _validateStartWithEmptyCloudSnapshotPair(
            localSummary: guardedLocalSummary,
            remoteSummary: guardedRemoteSummary,
            intentState: intentState,
          );
      if (guardedBlock != null) {
        return guardedBlock;
      }

      try {
        await _userAccountCleanupRepository.deleteLocalUserData(
          currentUser.uid,
        );
      } catch (error) {
        _logger.logError(
          'Start-with-empty-cloud local reset failed for ${currentUser.uid}: $error',
          error,
        );
        return const CloudActivationExecutionResult.failedFor(
          CloudActivationExecutionBlockReason.localResetFailed,
          message:
              'Не удалось безопасно очистить активное локальное рабочее пространство.',
        );
      }

      final LocalSnapshotSummary postResetSummary =
          await _localSnapshotSummaryService.summarize(
            includeActivationGuard: false,
          );
      final bool postResetSafe =
          postResetSummary.state == LocalSnapshotState.empty ||
          postResetSummary.state == LocalSnapshotState.hasOnlySystemData;
      if (!postResetSafe) {
        _logger.logError(
          'Post-reset local summary verification failed for ${currentUser.uid}. State: ${postResetSummary.state}',
        );
        return const CloudActivationExecutionResult.failedFor(
          CloudActivationExecutionBlockReason.localResetFailed,
          message:
              'Критическая ошибка: локальная база данных не была полностью очищена.',
        );
      }

      await _activationStateRepository.saveEnabledState(
        uid: currentUser.uid,
        scenario: CloudActivationChoice.startWithEmptyCloud.name,
        localFingerprint: guardedLocalSummary.fingerprint,
        remoteFingerprint: guardedRemoteSummary.fingerprint,
      );

      final DataModeState nextState = await refreshRuntimeMode();
      if (nextState.dataMode != DataMode.cloudEnabled) {
        _logger.logWarning(
          'Start-with-empty-cloud activation flag persisted for ${currentUser.uid}, but runtime mode stayed ${nextState.dataMode.name}.',
        );
        return const CloudActivationExecutionResult.failed(
          message:
              'Не удалось безопасно перевести приложение в новый пустой облачный режим.',
        );
      }

      final String target =
          exportResult.filePath ??
          exportResult.downloadUrl?.toString() ??
          'в системное хранилище';
      return CloudActivationExecutionResult.succeededWithMessage(
        'Локальные данные сохранены в backup ($target), активное рабочее пространство очищено, и приложение переключено на пустое облако.',
      );
    } catch (error) {
      _logger.logError(
        'Start-with-empty-cloud execution failed for ${currentUser.uid}: $error',
        error,
      );
      return CloudActivationExecutionResult.failed(message: error.toString());
    } finally {
      _runtimeGuard.release();
    }
  }

  Future<CloudActivationExecutionResult> confirmMigrateLocalToCloudPreflight({
    required AuthUser? currentUser,
    required CloudActivationIntentState intentState,
    required DataModeState? currentMode,
  }) async {
    final CloudActivationExecutionResult? commonBlock =
        await _validateCommonPreconditions(
          currentUser: currentUser,
          intentState: intentState,
          currentMode: currentMode,
          expectedChoice: CloudActivationChoice.migrateLocalToCloud,
        );
    if (commonBlock != null) {
      return commonBlock;
    }

    final LocalSnapshotSummary localSummary = await _localSnapshotSummaryService
        .summarize();
    final CloudSnapshotSummary remoteSummary =
        await _cloudSnapshotSummaryService.summarize(currentUser!.uid);
    final CloudActivationExecutionResult? precheckBlock =
        _validateMigrateLocalToCloudSnapshotPair(
          localSummary: localSummary,
          remoteSummary: remoteSummary,
          intentState: intentState,
        );
    if (precheckBlock != null) {
      return precheckBlock;
    }

    if (!_runtimeGuard.tryAcquire()) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.activationInProgress,
      );
    }

    try {
      final LocalToCloudMigrationPreflightResult preflight =
          await _localToCloudMigrationReadinessService.captureReadiness(
            uid: currentUser.uid,
          );
      if (!preflight.isReady) {
        return CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.migrationReadinessBlocked,
          message: _migrationReadinessBlockedMessage(preflight),
        );
      }

      final ExportBundle bundle = await _prepareExportBundleUseCase();
      const ExportBundleIntegrityService integrityService =
          ExportBundleIntegrityService();
      integrityService.verify(bundle);

      final ExportFileSaveResult exportResult = await _exportUserDataUseCase(
        const ExportUserDataParams(),
      );
      if (!exportResult.isSuccess) {
        return CloudActivationExecutionResult.failedFor(
          CloudActivationExecutionBlockReason.backupExportFailed,
          message:
              exportResult.errorMessage ??
              'Не удалось создать резервную копию локальных данных перед migrateLocalToCloud.',
        );
      }

      final LocalSnapshotSummary guardedLocalSummary =
          await _localSnapshotSummaryService.summarize(
            includeActivationGuard: false,
          );
      final CloudSnapshotSummary guardedRemoteSummary =
          await _cloudSnapshotSummaryService.summarize(currentUser.uid);
      final CloudActivationExecutionResult? guardedBlock =
          _validateMigrateLocalToCloudSnapshotPair(
            localSummary: guardedLocalSummary,
            remoteSummary: guardedRemoteSummary,
            intentState: intentState,
          );
      if (guardedBlock != null) {
        return guardedBlock;
      }
      if (guardedLocalSummary.fingerprint !=
              preflight.localSummary!.fingerprint ||
          guardedRemoteSummary.fingerprint != remoteSummary.fingerprint) {
        return const CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.staleReadiness,
          message:
              'Состояние изменилось после backup/export. Пройдите migrateLocalToCloud readiness ещё раз.',
        );
      }

      final DateTime now = DateTime.now().toUtc();
      final LocalToCloudMigrationState preparedState =
          _buildPreparedMigrationState(
            uid: currentUser.uid,
            preflight: preflight,
            remoteFingerprint: remoteSummary.fingerprint,
            localFingerprintBeforeUpload: guardedLocalSummary.fingerprint,
            remoteFingerprintBeforeUpload: guardedRemoteSummary.fingerprint,
            backupArtifactReference: _backupArtifactReference(exportResult),
            backupChecksum: bundle.integrity?.contentHash,
            createdAt: now,
          );
      await _migrationStateRepository.saveState(preparedState);

      return const CloudActivationExecutionResult.succeededWithMessage(
        'Подготовка migrateLocalToCloud сохранена: backup создан, integrity проверена, локальный и удалённый snapshot повторно подтверждены, а migration plan зафиксирован в durable state. Следующий шаг — controlled upload поверх этого состояния.',
      );
    } catch (error) {
      _logger.logError(
        'Migrate-local-to-cloud preflight failed for ${currentUser.uid}: $error',
        error,
      );
      return CloudActivationExecutionResult.failed(message: error.toString());
    } finally {
      _runtimeGuard.release();
    }
  }

  LocalToCloudMigrationState _buildPreparedMigrationState({
    required String uid,
    required LocalToCloudMigrationPreflightResult preflight,
    required String remoteFingerprint,
    required String localFingerprintBeforeUpload,
    required String remoteFingerprintBeforeUpload,
    required String backupArtifactReference,
    required String? backupChecksum,
    required DateTime createdAt,
  }) {
    final LocalSnapshotSummary localSummary = preflight.localSummary!;
    final LocalToCloudMigrationInventorySnapshot inventorySnapshot =
        preflight.inventorySnapshot!;
    final List<LocalToCloudMigrationPlanRow>
    planRows = <LocalToCloudMigrationPlanRow>[
      for (final MapEntry<String, List<LocalToCloudMigrationRow>> familyEntry
          in inventorySnapshot.rowsByFamily.entries)
        for (final LocalToCloudMigrationRow row in familyEntry.value)
          LocalToCloudMigrationPlanRow(
            familyKey: familyEntry.key,
            localRowId: row.localRowId,
            documentId: row.reusedDocumentId,
          ),
    ];

    return LocalToCloudMigrationState(
      uid: uid,
      stage: LocalToCloudMigrationStage.backupCreated,
      createdAt: createdAt,
      updatedAt: createdAt,
      plan: LocalToCloudMigrationPlan(
        migrationId: 'ltc-${createdAt.microsecondsSinceEpoch}',
        createdAt: createdAt,
        localFingerprint: localSummary.fingerprint,
        remoteFingerprint: remoteFingerprint,
        candidateFamilyKeys: inventorySnapshot.candidateFamilyKeys.toList()
          ..sort(),
        rows: List<LocalToCloudMigrationPlanRow>.unmodifiable(planRows),
      ),
      version: 2,
      backupArtifactReference: backupArtifactReference,
      backupChecksum: backupChecksum,
      localFingerprintBeforeUpload: localFingerprintBeforeUpload,
      remoteFingerprintBeforeUpload: remoteFingerprintBeforeUpload,
    );
  }

  String _backupArtifactReference(ExportFileSaveResult result) {
    return result.filePath ??
        result.downloadUrl?.toString() ??
        'backup-export-created';
  }

  Future<CloudActivationExecutionResult> confirmMigrateLocalToCloudExecution({
    required AuthUser? currentUser,
    required CloudActivationIntentState intentState,
    required DataModeState? currentMode,
    required Future<DataModeState> Function() refreshRuntimeMode,
  }) async {
    final CloudActivationExecutionResult? commonBlock =
        await _validateCommonPreconditions(
          currentUser: currentUser,
          intentState: intentState,
          currentMode: currentMode,
          expectedChoice: CloudActivationChoice.migrateLocalToCloud,
        );
    if (commonBlock != null) {
      return commonBlock;
    }

    final String uid = currentUser!.uid;
    final LocalToCloudMigrationState? existingState =
        await _migrationStateRepository.getStateForUid(uid);

    final LocalSnapshotSummary localSummary = await _localSnapshotSummaryService
        .summarize();
    final CloudSnapshotSummary remoteSummary =
        await _cloudSnapshotSummaryService.summarize(uid);

    final CloudActivationExecutionResult? precheckBlock =
        _validateMigrateLocalToCloudSnapshotPair(
          localSummary: localSummary,
          remoteSummary: remoteSummary,
          intentState: intentState,
          isResume: existingState != null,
        );
    if (precheckBlock != null) {
      return precheckBlock;
    }

    if (!_runtimeGuard.tryAcquire()) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.activationInProgress,
      );
    }

    try {
      if (existingState == null) {
        return const CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.pendingIntentMissing,
          message: 'Для migrateLocalToCloud нет подготовленного durable state.',
        );
      }

      if (existingState.uid != uid) {
        return const CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.migrationUidChanged,
          message: 'UID пользователя изменился в процессе миграции.',
        );
      }

      if (existingState.plan.localFingerprint != localSummary.fingerprint) {
        return const CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.migrationLocalDataChanged,
          message: 'Локальные данные изменились после preflight.',
        );
      }

      final DocumentSnapshot<Map<String, dynamic>> markerDoc = await _firestore
          .doc('users/$uid/migration_state/status')
          .get();
      if (markerDoc.exists) {
        final Map<String, dynamic> data = markerDoc.data()!;
        final String? remoteMigrationId = data['migrationId'] as String?;
        if (remoteMigrationId != existingState.plan.migrationId) {
          return const CloudActivationExecutionResult.blocked(
            CloudActivationExecutionBlockReason.migrationRemoteOccupied,
            message:
                'На удалённом сервере обнаружена другая активная миграция.',
          );
        }
      } else {
        if (remoteSummary.state != RemoteSnapshotState.empty) {
          return const CloudActivationExecutionResult.blocked(
            CloudActivationExecutionBlockReason.migrationRemoteOccupied,
            message: 'Удалённый сервер содержит данные, а marker отсутствует.',
          );
        }
      }

      final LocalToCloudMigrationUploadResult uploadResult =
          await _uploadService.uploadPreparedMigration(uid: uid);
      if (uploadResult.status != LocalToCloudMigrationUploadStatus.succeeded) {
        if (uploadResult.status == LocalToCloudMigrationUploadStatus.blocked) {
          final CloudActivationExecutionBlockReason mappedReason =
              switch (uploadResult.blockReason) {
                LocalToCloudMigrationUploadBlockReason.missingPreparedState =>
                  CloudActivationExecutionBlockReason.pendingIntentMissing,
                LocalToCloudMigrationUploadBlockReason.invalidPreparedState =>
                  CloudActivationExecutionBlockReason.migrationReadinessBlocked,
                LocalToCloudMigrationUploadBlockReason.planMismatch =>
                  CloudActivationExecutionBlockReason.migrationPayloadMismatch,
                null =>
                  CloudActivationExecutionBlockReason.migrationUnknownFailure,
              };
          return CloudActivationExecutionResult.blocked(
            mappedReason,
            message: uploadResult.message,
          );
        } else {
          return CloudActivationExecutionResult.blocked(
            CloudActivationExecutionBlockReason.migrationNetworkRetryable,
            message: uploadResult.message,
          );
        }
      }

      final LocalToCloudMigrationRemoteVerificationResult verifyResult =
          await _remoteVerificationService.verifyUploadedGraph(uid: uid);
      if (verifyResult.status !=
          LocalToCloudMigrationRemoteVerificationStatus.succeeded) {
        final CloudActivationExecutionBlockReason mappedReason =
            switch (verifyResult.blockReason) {
              LocalToCloudMigrationRemoteVerificationBlockReason
                  .missingPreparedState =>
                CloudActivationExecutionBlockReason.pendingIntentMissing,
              LocalToCloudMigrationRemoteVerificationBlockReason
                  .invalidPreparedState =>
                CloudActivationExecutionBlockReason.migrationReadinessBlocked,
              LocalToCloudMigrationRemoteVerificationBlockReason.planMismatch =>
                CloudActivationExecutionBlockReason.migrationPayloadMismatch,
              LocalToCloudMigrationRemoteVerificationBlockReason
                  .remoteDataMismatch =>
                CloudActivationExecutionBlockReason.migrationPayloadMismatch,
              null =>
                CloudActivationExecutionBlockReason.migrationUnknownFailure,
            };
        return CloudActivationExecutionResult.blocked(
          mappedReason,
          message: verifyResult.message,
        );
      }

      final LocalToCloudMigrationLocalOwnershipConversionResult convertResult =
          await _localOwnershipConversionService.convertVerifiedMigration(
            uid: uid,
          );
      if (convertResult.status !=
          LocalToCloudMigrationLocalOwnershipConversionStatus.succeeded) {
        final CloudActivationExecutionBlockReason mappedReason =
            switch (convertResult.blockReason) {
              LocalToCloudMigrationLocalOwnershipConversionBlockReason
                  .missingPreparedState =>
                CloudActivationExecutionBlockReason.pendingIntentMissing,
              LocalToCloudMigrationLocalOwnershipConversionBlockReason
                  .invalidPreparedState =>
                CloudActivationExecutionBlockReason.migrationReadinessBlocked,
              LocalToCloudMigrationLocalOwnershipConversionBlockReason
                  .integrityViolation =>
                CloudActivationExecutionBlockReason
                    .migrationConversionIntegrityFailed,
              null =>
                CloudActivationExecutionBlockReason.migrationUnknownFailure,
            };
        return CloudActivationExecutionResult.blocked(
          mappedReason,
          message: convertResult.message,
        );
      }

      await _activationStateRepository.saveEnabledState(
        uid: uid,
        scenario: CloudActivationChoice.migrateLocalToCloud.name,
        localFingerprint: existingState.plan.localFingerprint,
        remoteFingerprint: existingState.plan.remoteFingerprint,
      );

      await _firestore.doc('users/$uid/migration_state/status').set(
        <String, dynamic>{'stage': 'completed'},
        SetOptions(merge: true),
      );

      final LocalToCloudMigrationState? latestState =
          await _migrationStateRepository.getStateForUid(uid);
      if (latestState != null) {
        await _migrationStateRepository.saveState(
          LocalToCloudMigrationState(
            uid: uid,
            stage: LocalToCloudMigrationStage.completed,
            createdAt: latestState.createdAt,
            updatedAt: DateTime.now().toUtc(),
            plan: latestState.plan,
            version: latestState.version,
            backupArtifactReference: latestState.backupArtifactReference,
            backupChecksum: latestState.backupChecksum,
            localFingerprintBeforeUpload:
                latestState.localFingerprintBeforeUpload,
            remoteFingerprintBeforeUpload:
                latestState.remoteFingerprintBeforeUpload,
            uploadedRowCountsByFamily: latestState.uploadedRowCountsByFamily,
            verifiedRowCountsByFamily: latestState.verifiedRowCountsByFamily,
          ),
        );
      }

      final DataModeState nextState = await refreshRuntimeMode();
      if (nextState.dataMode != DataMode.cloudEnabled) {
        _logger.logWarning(
          'Migrate local-to-cloud completed for $uid, but runtime mode stayed ${nextState.dataMode.name}.',
        );
        return const CloudActivationExecutionResult.failed(
          message:
              'Не удалось безопасно перевести приложение в облачный режим.',
        );
      }

      return const CloudActivationExecutionResult.succeededWithMessage(
        'Миграция успешно завершена! Данные перенесены в облако, локальный outbox очищен, и приложение переключено в облачный режим.',
      );
    } catch (error) {
      _logger.logError(
        'Migrate-local-to-cloud execution failed for ${currentUser.uid}: $error',
        error,
      );
      return CloudActivationExecutionResult.failed(message: error.toString());
    } finally {
      _runtimeGuard.release();
    }
  }

  CloudActivationExecutionResult? _validateSnapshotPair({
    required LocalSnapshotSummary localSummary,
    required CloudSnapshotSummary remoteSummary,
    required CloudActivationIntentState intentState,
  }) {
    final bool localSafe =
        localSummary.state == LocalSnapshotState.empty ||
        localSummary.state == LocalSnapshotState.hasOnlySystemData;
    if (!localSafe) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.localNotEmpty,
      );
    }

    if (remoteSummary.state == RemoteSnapshotState.hasOnlyMetadata) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteMetadataPresent,
      );
    }
    if (remoteSummary.state == RemoteSnapshotState.hasUserData ||
        remoteSummary.state == RemoteSnapshotState.hasTombstonesOnly ||
        remoteSummary.state == RemoteSnapshotState.activationInProgress) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteNotEmpty,
      );
    }
    if (remoteSummary.state == RemoteSnapshotState.permissionDenied) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remotePermissionDenied,
      );
    }
    if (remoteSummary.state == RemoteSnapshotState.unavailable ||
        remoteSummary.state == RemoteSnapshotState.unknown ||
        remoteSummary.state == RemoteSnapshotState.unauthenticated) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteUnavailable,
      );
    }

    if (intentState.localFingerprint != null &&
        intentState.localFingerprint != localSummary.fingerprint) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.staleReadiness,
      );
    }
    if (intentState.remoteFingerprint != null &&
        intentState.remoteFingerprint != remoteSummary.fingerprint) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.staleReadiness,
      );
    }

    return null;
  }

  Future<CloudActivationExecutionResult?> _validateCommonPreconditions({
    required AuthUser? currentUser,
    required CloudActivationIntentState intentState,
    required DataModeState? currentMode,
    required CloudActivationChoice expectedChoice,
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
    if (intentState.stage != CloudActivationIntentStage.pendingChoice) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.pendingIntentMissing,
      );
    }
    if (intentState.pendingChoice != expectedChoice) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.invalidPendingIntent,
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

    return null;
  }

  CloudActivationExecutionResult? _validateStartWithEmptyCloudSnapshotPair({
    required LocalSnapshotSummary localSummary,
    required CloudSnapshotSummary remoteSummary,
    required CloudActivationIntentState intentState,
  }) {
    if (localSummary.state != LocalSnapshotState.hasUserData) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.localNotEmpty,
      );
    }

    if (remoteSummary.state == RemoteSnapshotState.hasOnlyMetadata) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteMetadataPresent,
      );
    }
    if (remoteSummary.state == RemoteSnapshotState.hasUserData ||
        remoteSummary.state == RemoteSnapshotState.hasTombstonesOnly ||
        remoteSummary.state == RemoteSnapshotState.activationInProgress) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteNotEmpty,
      );
    }
    if (remoteSummary.state == RemoteSnapshotState.permissionDenied) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remotePermissionDenied,
      );
    }
    if (remoteSummary.state != RemoteSnapshotState.empty) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteUnavailable,
      );
    }

    if (intentState.localFingerprint != null &&
        intentState.localFingerprint != localSummary.fingerprint) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.staleReadiness,
      );
    }
    if (intentState.remoteFingerprint != null &&
        intentState.remoteFingerprint != remoteSummary.fingerprint) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.staleReadiness,
      );
    }

    return null;
  }

  CloudActivationExecutionResult? _validateReplaceLocalWithCloudSnapshotPair({
    required LocalSnapshotSummary localSummary,
    required CloudSnapshotSummary remoteSummary,
    required CloudActivationIntentState intentState,
  }) {
    final bool localSafe =
        localSummary.state == LocalSnapshotState.empty ||
        localSummary.state == LocalSnapshotState.hasOnlySystemData;
    if (!localSafe) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.localNotEmpty,
      );
    }

    if (remoteSummary.state == RemoteSnapshotState.permissionDenied) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remotePermissionDenied,
      );
    }
    if (remoteSummary.state == RemoteSnapshotState.unavailable ||
        remoteSummary.state == RemoteSnapshotState.unknown ||
        remoteSummary.state == RemoteSnapshotState.unauthenticated) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteUnavailable,
      );
    }
    if (remoteSummary.state != RemoteSnapshotState.hasUserData) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteNotEmpty,
      );
    }

    if (intentState.localFingerprint != null &&
        intentState.localFingerprint != localSummary.fingerprint) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.staleReadiness,
      );
    }
    if (intentState.remoteFingerprint != null &&
        intentState.remoteFingerprint != remoteSummary.fingerprint) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.staleReadiness,
      );
    }

    return null;
  }

  CloudActivationExecutionResult? _validateMigrateLocalToCloudSnapshotPair({
    required LocalSnapshotSummary localSummary,
    required CloudSnapshotSummary remoteSummary,
    required CloudActivationIntentState intentState,
    bool isResume = false,
  }) {
    if (localSummary.state != LocalSnapshotState.hasUserData &&
        localSummary.state != LocalSnapshotState.hasPendingOutbox) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.localNotEmpty,
      );
    }

    if (remoteSummary.state == RemoteSnapshotState.hasOnlyMetadata) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remoteMetadataPresent,
      );
    }
    if (!isResume) {
      if (remoteSummary.state == RemoteSnapshotState.hasUserData ||
          remoteSummary.state == RemoteSnapshotState.hasTombstonesOnly ||
          remoteSummary.state == RemoteSnapshotState.activationInProgress) {
        return const CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.remoteNotEmpty,
        );
      }
    }
    if (remoteSummary.state == RemoteSnapshotState.permissionDenied) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.remotePermissionDenied,
      );
    }
    if (!isResume) {
      if (remoteSummary.state != RemoteSnapshotState.empty) {
        return const CloudActivationExecutionResult.blocked(
          CloudActivationExecutionBlockReason.remoteUnavailable,
        );
      }
    }

    if (intentState.localFingerprint != null &&
        intentState.localFingerprint != localSummary.fingerprint) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.staleReadiness,
      );
    }
    if (intentState.remoteFingerprint != null &&
        intentState.remoteFingerprint != remoteSummary.fingerprint) {
      return const CloudActivationExecutionResult.blocked(
        CloudActivationExecutionBlockReason.staleReadiness,
      );
    }

    return null;
  }

  String _migrationReadinessBlockedMessage(
    LocalToCloudMigrationPreflightResult preflight,
  ) {
    return switch (preflight.blockReason) {
      LocalToCloudMigrationPreflightBlockReason.freezeAlreadyActive =>
        'Migration preflight уже выполняется или freeze ещё не снят. Повторите попытку позже.',
      LocalToCloudMigrationPreflightBlockReason.localSnapshotNotMigratable =>
        'Локальный snapshot больше не подходит для migrateLocalToCloud: нужны пользовательские данные без pending outbox.',
      LocalToCloudMigrationPreflightBlockReason.activeMutationsDetected =>
        'Во время preflight обнаружены активные локальные изменения. Migration readiness остаётся fail-closed.',
      LocalToCloudMigrationPreflightBlockReason.inventoryReadinessBlocked =>
        preflight.readinessResult != null &&
                preflight.readinessResult!.issues.isNotEmpty
            ? preflight.readinessResult!.issues.first.message
            : 'Inventory validator заблокировал migrateLocalToCloud.',
      null => 'Migration readiness preflight завершился блокировкой.',
    };
  }
}

final Provider<CloudActivationExecutionService>
cloudActivationExecutionServiceProvider =
    Provider<CloudActivationExecutionService>((Ref ref) {
      return CloudActivationExecutionService(
        firestore: ref.watch(firestoreProvider),
        uploadService: ref.watch(localToCloudMigrationUploadServiceProvider),
        remoteVerificationService: ref.watch(
          localToCloudMigrationRemoteVerificationServiceProvider,
        ),
        localOwnershipConversionService: ref.watch(
          localToCloudMigrationLocalOwnershipConversionServiceProvider,
        ),
        activationStateRepository: ref.watch(
          cloudActivationStateRepositoryProvider,
        ),
        migrationStateRepository: ref.watch(
          localToCloudMigrationStateRepositoryProvider,
        ),
        entitlementRepository: ref.watch(cloudEntitlementRepositoryProvider),
        localSnapshotSummaryService: ref.watch(
          localSnapshotSummaryServiceProvider,
        ),
        cloudSnapshotSummaryService: ref.watch(
          cloudSnapshotSummaryServiceProvider,
        ),
        localToCloudMigrationReadinessService: ref.watch(
          localToCloudMigrationReadinessServiceProvider,
        ),
        prepareExportBundleUseCase: ref.watch(
          prepareExportBundleUseCaseProvider,
        ),
        exportUserDataUseCase: ref.watch(exportUserDataUseCaseProvider),
        userAccountCleanupRepository: ref.watch(
          userAccountCleanupRepositoryProvider,
        ),
        runtimeGuard: ref.watch(cloudActivationRuntimeGuardProvider),
        logger: ref.watch(loggerServiceProvider),
      );
    });
