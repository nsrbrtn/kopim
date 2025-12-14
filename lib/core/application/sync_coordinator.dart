import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';

/// Координатор, который управляет жизненным циклом синхронизации:
/// - не запускает SyncService для гостя/в офлайне;
/// - запускает инициализацию SyncService после появления пользователя;
/// - останавливает SyncService при logout (через autoDispose провайдера).
final Provider<void> syncCoordinatorProvider = Provider<void>((Ref ref) {
  if (kIsWeb) {
    return;
  }

  ProviderSubscription<SyncService>? syncSubscription;

  void stopSync() {
    syncSubscription?.close();
    syncSubscription = null;
  }

  Future<void> startSyncForUser(AuthUser user) async {
    if (user.isGuest) {
      stopSync();
      return;
    }

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

  ref.onDispose(stopSync);

  ref.listen<AsyncValue<AuthUser?>>(authControllerProvider, (
    AsyncValue<AuthUser?>? previous,
    AsyncValue<AuthUser?> next,
  ) {
    final AuthUser? user = next.asData?.value;
    if (user == null) {
      stopSync();
      return;
    }
    unawaited(startSyncForUser(user));
  }, fireImmediately: true);
});
