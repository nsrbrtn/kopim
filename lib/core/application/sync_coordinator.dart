import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/application/firebase_availability.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/application/sync_preferences_provider.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';

/// Координатор, который управляет жизненным циклом синхронизации:
/// - не запускает SyncService для гостя/в офлайне;
/// - запускает инициализацию SyncService после появления пользователя;
/// - останавливает SyncService при logout (через autoDispose провайдера).
final Provider<void> syncCoordinatorProvider = Provider<void>((Ref ref) {
  if (kIsWeb || AppRuntimeConfig.isOffline) {
    return;
  }

  // If Firebase is unavailable, we can't sync.
  final FirebaseAvailabilityState availability = ref.watch(
    firebaseAvailabilityProvider,
  );
  if (availability.isAvailable == false) {
    return;
  }

  ProviderSubscription<SyncService>? syncSubscription;
  AuthUser? currentUser = ref.watch(authControllerProvider).asData?.value;
  bool? isOnlineSyncEnabled = ref
      .watch(onlineSyncPreferencesControllerProvider)
      .maybeWhen(data: (bool value) => value, orElse: () => null);

  void stopSync() {
    syncSubscription?.close();
    syncSubscription = null;
  }

  Future<void> startSyncForUser(AuthUser user) async {
    syncSubscription ??= ref.listen<SyncService>(
      syncServiceProvider,
      (SyncService? previous, SyncService next) {},
      fireImmediately: true,
    );

    unawaited(
      ref.read(syncServiceProvider).initialize().catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'sync_coordinator',
            context: ErrorDescription('while initializing SyncService'),
          ),
        );
      }),
    );
  }

  void reevaluateSyncState() {
    final AuthUser? user = currentUser;
    final bool canSync =
        isOnlineSyncEnabled == true && user != null && !user.isGuest;
    if (!canSync) {
      stopSync();
      return;
    }
    unawaited(startSyncForUser(user));
  }

  ref.onDispose(stopSync);

  ref.listen<AsyncValue<bool>>(onlineSyncPreferencesControllerProvider, (
    AsyncValue<bool>? previous,
    AsyncValue<bool> next,
  ) {
    isOnlineSyncEnabled = next.maybeWhen(
      data: (bool value) => value,
      orElse: () => null,
    );
    reevaluateSyncState();
  }, fireImmediately: true);

  ref.listen<AsyncValue<AuthUser?>>(authControllerProvider, (
    AsyncValue<AuthUser?>? previous,
    AsyncValue<AuthUser?> next,
  ) {
    currentUser = next.asData?.value;
    reevaluateSyncState();
  }, fireImmediately: true);
});
