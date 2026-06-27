import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/data/cloud_metadata_repository.dart';
import 'package:kopim/features/profile/data/fresh_upload_finalization_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/cloud_metadata.dart';
import 'package:kopim/features/profile/domain/entities/fresh_upload_finalization_marker.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';

part 'data_mode_controller.g.dart';

class DataModeState {
  const DataModeState({
    required this.dataMode,
    required this.entitlementState,
    required this.migrationDecision,
    this.cloudDataState,
    this.requiresFreshCloudUpload = false,
    this.requiresFreshUploadFinalization = false,
    this.isSyncBlockedByCloudState = false,
  });

  final DataMode dataMode;
  final CloudEntitlementState entitlementState;
  final MigrationDecision migrationDecision;
  final CloudDataState? cloudDataState;
  final bool requiresFreshCloudUpload;
  final bool requiresFreshUploadFinalization;
  final bool isSyncBlockedByCloudState;

  DataModeState copyWith({
    DataMode? dataMode,
    CloudEntitlementState? entitlementState,
    MigrationDecision? migrationDecision,
    CloudDataState? cloudDataState,
    bool? requiresFreshCloudUpload,
    bool? requiresFreshUploadFinalization,
    bool? isSyncBlockedByCloudState,
  }) {
    return DataModeState(
      dataMode: dataMode ?? this.dataMode,
      entitlementState: entitlementState ?? this.entitlementState,
      migrationDecision: migrationDecision ?? this.migrationDecision,
      cloudDataState: cloudDataState ?? this.cloudDataState,
      requiresFreshCloudUpload:
          requiresFreshCloudUpload ?? this.requiresFreshCloudUpload,
      requiresFreshUploadFinalization:
          requiresFreshUploadFinalization ??
          this.requiresFreshUploadFinalization,
      isSyncBlockedByCloudState:
          isSyncBlockedByCloudState ?? this.isSyncBlockedByCloudState,
    );
  }
}

@Riverpod(keepAlive: true)
class DataModeController extends _$DataModeController {
  static const String _cacheKeyPrefix = 'profile.cloud_data_state.';

  @override
  FutureOr<DataModeState> build() async {
    final LoggerService logger = ref.read(loggerServiceProvider);
    final AppCapabilities capabilities = ref.watch(appCapabilitiesProvider);

    if (!capabilities.canRunCloudSync) {
      logger.logInfo(
        'DataModeController: sync capabilities disabled, forcing localOnly mode.',
      );
      return const DataModeState(
        dataMode: DataMode.localOnly,
        entitlementState: CloudEntitlementState.unavailable,
        migrationDecision: MigrationDecision.none,
      );
    }

    final CloudEntitlementRepository repository = ref.watch(
      cloudEntitlementRepositoryProvider,
    );
    final CloudEntitlementState entitlement = await repository.getCachedState();
    logger.logInfo(
      'DataModeController: cached entitlement=$entitlement for flavor=${AppRuntimeConfig.flavor.name}.',
    );

    final Stream<AuthUser?> authStream = ref
        .watch(cloudAuthRepositoryProvider)
        .authStateChanges();

    final StreamSubscription<AuthUser?> sub = authStream.listen((
      AuthUser? user,
    ) {
      unawaited(_refreshStateForAuthChange(user));
    });
    ref.onDispose(() => sub.cancel());

    final AuthUser? currentCloudUser = ref
        .watch(cloudAuthRepositoryProvider)
        .currentUser;

    final DataModeState initial = await _calculateState(
      currentCloudUser,
      entitlement,
    );
    logger.logInfo(
      'DataModeController: initial mode=${initial.dataMode.name}, cloudUser=${currentCloudUser?.uid ?? 'none'}, entitlement=${initial.entitlementState.name}.',
    );
    unawaited(
      ref
          .read(appDatabaseProvider)
          .updateCurrentSyncState(
            currentCloudUser?.uid,
            initial.dataMode == DataMode.cloudEnabled,
          ),
    );
    return initial;
  }

  Future<void> activateEntitlementKey(String key) async {
    final AppCapabilities capabilities = ref.read(appCapabilitiesProvider);
    if (!capabilities.canRunCloudSync) return;

    state = const AsyncValue<DataModeState>.loading();
    try {
      ref
          .read(loggerServiceProvider)
          .logInfo(
            'DataModeController: activating entitlement key for flavor=${AppRuntimeConfig.flavor.name}.',
          );
      final CloudEntitlementRepository repository = ref.read(
        cloudEntitlementRepositoryProvider,
      );
      final CloudEntitlementResult result = await repository.activateKey(key);

      final AuthUser? currentCloudUser = ref
          .read(cloudAuthRepositoryProvider)
          .currentUser;
      final DataModeState nextState = await _calculateState(
        currentCloudUser,
        result.state,
      );
      ref
          .read(loggerServiceProvider)
          .logInfo(
            'DataModeController: entitlement activation result success=${result.success}, state=${result.state.name}, mode=${nextState.dataMode.name}.',
          );
      _setState(nextState);
    } catch (e, st) {
      state = AsyncValue<DataModeState>.error(e, st);
    }
  }

  Future<void> refreshEntitlement() async {
    final AppCapabilities capabilities = ref.read(appCapabilitiesProvider);
    if (!capabilities.canRunCloudSync) return;

    final LoggerService logger = ref.read(loggerServiceProvider);
    logger.logInfo(
      'DataModeController: force refreshing entitlement claims...',
    );

    final AuthRepository authRepo = ref.read(cloudAuthRepositoryProvider);
    await authRepo.forceRefreshIdToken();

    final CloudEntitlementRepository entitlementRepo = ref.read(
      cloudEntitlementRepositoryProvider,
    );
    final CloudEntitlementState entitlement = await entitlementRepo
        .refreshFromCurrentToken();

    final AuthUser? currentCloudUser = authRepo.currentUser;
    final DataModeState nextState = await _calculateState(
      currentCloudUser,
      entitlement,
    );

    logger.logInfo(
      'DataModeController: refreshEntitlement done. Next mode=${nextState.dataMode.name}, entitlement=${nextState.entitlementState.name}',
    );

    _setState(nextState);
  }

  Future<void> setMigrationDecision(MigrationDecision decision) async {
    final DataModeState? current = state.value;
    if (current == null) return;

    final AuthUser? currentCloudUser = ref
        .read(cloudAuthRepositoryProvider)
        .currentUser;
    final DataModeState nextState = await _calculateState(
      currentCloudUser,
      current.entitlementState,
      decisionOverride: decision,
    );
    _setState(nextState);
  }

  Future<void> _updateState(
    AuthUser? cloudUser,
    CloudEntitlementState entitlement,
  ) async {
    state = const AsyncValue<DataModeState>.loading();
    try {
      final DataModeState nextState = await _calculateState(
        cloudUser,
        entitlement,
      );
      ref
          .read(loggerServiceProvider)
          .logInfo(
            'DataModeController: auth change cloudUser=${cloudUser?.uid ?? 'none'}, entitlement=${entitlement.name}, nextMode=${nextState.dataMode.name}.',
          );
      _setState(nextState);
    } catch (e, st) {
      state = AsyncValue<DataModeState>.error(e, st);
    }
  }

  Future<void> _refreshStateForAuthChange(AuthUser? cloudUser) async {
    final CloudEntitlementState entitlement = await _currentEntitlementState();
    ref
        .read(loggerServiceProvider)
        .logInfo(
          'DataModeController: refreshed entitlement=${entitlement.name} for auth change cloudUser=${cloudUser?.uid ?? 'none'}.',
        );
    await _updateState(cloudUser, entitlement);
  }

  Future<DataModeState> refreshForCurrentContext() async {
    final CloudEntitlementState entitlement = await _currentEntitlementState();
    final AuthUser? currentCloudUser = ref
        .read(cloudAuthRepositoryProvider)
        .currentUser;
    final DataModeState nextState = await _calculateState(
      currentCloudUser,
      entitlement,
    );
    _setState(nextState);
    return nextState;
  }

  Future<CloudEntitlementState> _currentEntitlementState() {
    return ref.read(cloudEntitlementRepositoryProvider).getCachedState();
  }

  Future<void> _saveCachedCloudDataState(
    String uid,
    CloudDataState state,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cacheKeyPrefix$uid', state.name);
    } catch (_) {}
  }

  Future<DataModeState> _calculateState(
    AuthUser? cloudUser,
    CloudEntitlementState entitlement, {
    MigrationDecision? decisionOverride,
  }) async {
    final LoggerService logger = ref.read(loggerServiceProvider);
    final AppCapabilities capabilities = ref.read(appCapabilitiesProvider);

    if (!capabilities.canRunCloudSync) {
      return const DataModeState(
        dataMode: DataMode.localOnly,
        entitlementState: CloudEntitlementState.unavailable,
        migrationDecision: MigrationDecision.none,
      );
    }

    if (entitlement != CloudEntitlementState.active) {
      logger.logInfo(
        'DataModeController: entitlement=${entitlement.name}, keeping localOnly until key is active.',
      );
      return DataModeState(
        dataMode: DataMode.localOnly,
        entitlementState: entitlement,
        migrationDecision: MigrationDecision.none,
      );
    }

    if (cloudUser == null) {
      logger.logInfo(
        'DataModeController: entitlement active but no cloud user, keeping localOnly.',
      );
      return DataModeState(
        dataMode: DataMode.localOnly,
        entitlementState: entitlement,
        migrationDecision: MigrationDecision.none,
      );
    }

    final CloudActivationStateRepository activationStateRepository = ref.read(
      cloudActivationStateRepositoryProvider,
    );
    final bool hasActivationFlag =
        await activationStateRepository.getStateForUid(cloudUser.uid) != null;

    // Fetch cloud data state from repository with offline cache fallback
    CloudMetadata? metadata;
    bool metadataReadFailed = false;
    try {
      metadata = await ref
          .read(cloudMetadataRepositoryProvider)
          .getMetadata(cloudUser.uid);
      if (metadata != null) {
        await _saveCachedCloudDataState(cloudUser.uid, metadata.cloudDataState);
      }
    } catch (e) {
      metadataReadFailed = true;
      logger.logError('DataModeController: failed to fetch cloud metadata: $e');
    }

    final CloudDataState cloudState;
    if (metadata != null) {
      cloudState = metadata.cloudDataState;
    } else if (metadataReadFailed) {
      cloudState = CloudDataState.cleanupPending;
    } else {
      if (hasActivationFlag) {
        // Document missing but activation flag exists -> require fresh upload (fail closed)
        cloudState = CloudDataState.deleted;
      } else {
        // Default to active so they can perform first-time activation
        cloudState = CloudDataState.active;
      }
    }

    final bool isSyncBlocked =
        cloudState == CloudDataState.cleanupPending ||
        cloudState == CloudDataState.deleted ||
        cloudState == CloudDataState.freshUploadInProgress;

    final bool requiresFreshUpload =
        cloudState == CloudDataState.deleted &&
        entitlement == CloudEntitlementState.active;

    final bool requiresFreshUploadFinalization =
        cloudState == CloudDataState.active &&
        metadata?.freshUploadSessionId != null &&
        !await _hasCompletedFreshUploadFinalization(
          uid: cloudUser.uid,
          uploadSessionId: metadata!.freshUploadSessionId!,
        );

    if (requiresFreshUploadFinalization) {
      logger.logInfo(
        'DataModeController: remote Fresh Upload is active, but local finalization marker is missing. Forced localOnly.',
      );
      return DataModeState(
        dataMode: DataMode.localOnly,
        entitlementState: entitlement,
        migrationDecision: decisionOverride ?? MigrationDecision.none,
        cloudDataState: cloudState,
        requiresFreshUploadFinalization: true,
        isSyncBlockedByCloudState: true,
      );
    }

    if (isSyncBlocked) {
      logger.logInfo(
        'DataModeController: sync blocked by cloudDataState=${cloudState.name}. Forced localOnly.',
      );
      return DataModeState(
        dataMode: DataMode.localOnly,
        entitlementState: entitlement,
        migrationDecision: decisionOverride ?? MigrationDecision.none,
        cloudDataState: cloudState,
        requiresFreshCloudUpload: requiresFreshUpload,
        isSyncBlockedByCloudState: true,
      );
    }

    if (!hasActivationFlag) {
      logger.logInfo(
        'DataModeController: cloud user=${cloudUser.uid} has no activation flag, keeping localOnly.',
      );
      return DataModeState(
        dataMode: DataMode.localOnly,
        entitlementState: entitlement,
        migrationDecision: MigrationDecision.none,
        cloudDataState: cloudState,
      );
    }

    final bool hasLocalData = await ref
        .read(appDatabaseProvider)
        .hasAnyLocalOnlyData();
    final MigrationDecision decision =
        decisionOverride ?? MigrationDecision.none;

    if (hasLocalData) {
      logger.logInfo(
        'DataModeController: local data detected for cloud user ${cloudUser.uid}, keeping cloudBlockedByLocalData until migration exists.',
      );
      return DataModeState(
        dataMode: DataMode.cloudBlockedByLocalData,
        entitlementState: entitlement,
        migrationDecision: decision,
        cloudDataState: cloudState,
      );
    }

    logger.logInfo(
      'DataModeController: entitlement active, cloud user=${cloudUser.uid}, local data absent, enabling cloud mode.',
    );
    return DataModeState(
      dataMode: DataMode.cloudEnabled,
      entitlementState: entitlement,
      migrationDecision: MigrationDecision.none,
      cloudDataState: cloudState,
    );
  }

  void _setState(DataModeState nextState) {
    state = AsyncValue<DataModeState>.data(nextState);
    final String? currentUid = ref
        .read(cloudAuthRepositoryProvider)
        .currentUser
        ?.uid;
    final bool syncActive = nextState.dataMode == DataMode.cloudEnabled;
    unawaited(
      ref
          .read(appDatabaseProvider)
          .updateCurrentSyncState(currentUid, syncActive),
    );
  }

  Future<bool> _hasCompletedFreshUploadFinalization({
    required String uid,
    required String uploadSessionId,
  }) async {
    final FreshUploadFinalizationMarker? marker = await ref
        .read(freshUploadFinalizationRepositoryProvider)
        .getMarkerForUid(uid);
    return marker?.uploadSessionId == uploadSessionId;
  }
}
