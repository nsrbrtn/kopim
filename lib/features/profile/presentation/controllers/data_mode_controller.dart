import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';

part 'data_mode_controller.g.dart';

class DataModeState {
  const DataModeState({
    required this.dataMode,
    required this.entitlementState,
    required this.migrationDecision,
  });

  final DataMode dataMode;
  final CloudEntitlementState entitlementState;
  final MigrationDecision migrationDecision;

  DataModeState copyWith({
    DataMode? dataMode,
    CloudEntitlementState? entitlementState,
    MigrationDecision? migrationDecision,
  }) {
    return DataModeState(
      dataMode: dataMode ?? this.dataMode,
      entitlementState: entitlementState ?? this.entitlementState,
      migrationDecision: migrationDecision ?? this.migrationDecision,
    );
  }
}

@Riverpod(keepAlive: true)
class DataModeController extends _$DataModeController {
  @override
  FutureOr<DataModeState> build() async {
    final LoggerService logger = ref.read(loggerServiceProvider);
    if (AppRuntimeConfig.isOfflineOnlyDistribution) {
      logger.logInfo(
        'DataModeController: offline-only distribution, forcing localOnly mode.',
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

    // Также будем слушать пользователя
    // Но чтобы не было циклических зависимостей (ведь activeAuthRepository зависит от DataMode),
    // мы будем слушать FirebaseAuth (из firebaseAuthProvider) или cloudAuthRepositoryProvider.
    // Давайте лучше слушать cloudAuthRepositoryProvider.authStateChanges() напрямую!
    final Stream<AuthUser?> authStream = ref
        .watch(cloudAuthRepositoryProvider)
        .authStateChanges();

    // Подписываемся на стрим аутентификации
    final StreamSubscription<AuthUser?> sub = authStream.listen((
      AuthUser? user,
    ) {
      unawaited(_refreshStateForAuthChange(user));
    });
    ref.onDispose(() => sub.cancel());

    final AuthUser? currentCloudUser = ref
        .watch(cloudAuthRepositoryProvider)
        .currentUser;

    // Вычисляем начальное состояние
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
    if (AppRuntimeConfig.isOfflineOnlyDistribution) return;

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

  Future<DataModeState> _calculateState(
    AuthUser? cloudUser,
    CloudEntitlementState entitlement, {
    MigrationDecision? decisionOverride,
  }) async {
    final LoggerService logger = ref.read(loggerServiceProvider);
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
    if (!hasActivationFlag) {
      logger.logInfo(
        'DataModeController: cloud user=${cloudUser.uid} has no activation flag, keeping localOnly.',
      );
      return DataModeState(
        dataMode: DataMode.localOnly,
        entitlementState: entitlement,
        migrationDecision: MigrationDecision.none,
      );
    }

    // Проверяем наличие локальных данных в БД
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
      );
    }

    // Если локальных данных нет и пользователь залогинен с активным ключом:
    logger.logInfo(
      'DataModeController: entitlement active, cloud user=${cloudUser.uid}, local data absent, enabling cloud mode.',
    );
    return DataModeState(
      dataMode: DataMode.cloudEnabled,
      entitlementState: entitlement,
      migrationDecision: MigrationDecision.none,
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
}
