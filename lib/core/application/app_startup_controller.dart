import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/utils/platform_support.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/application/firebase_availability.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/utils/timezone_utils.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';

part 'app_startup_controller.g.dart';

typedef AppStartupResult = AsyncValue<void>;

@Riverpod(keepAlive: true)
class AppStartupController extends _$AppStartupController {
  @visibleForTesting
  static bool? debugIsWebOverride;

  static const Duration _webSyncInterval = Duration(minutes: 2);

  Completer<void>? _initializationCompleter;
  Timer? _webSyncTimer;

  @override
  AppStartupResult build() {
    return const AsyncValue<void>.loading();
  }

  Future<void> initialize() async {
    if (_initializationCompleter != null) {
      await _initializationCompleter!.future;
      return;
    }

    final Completer<void> completer = Completer<void>();
    _initializationCompleter = completer;

    state = const AsyncValue<void>.loading();

    try {
      final LoggerService logger = ref.read(loggerServiceProvider);
      final AppCapabilities capabilities = ref.read(appCapabilitiesProvider);
      logger.logInfo(
        'AppStartupController: initialize start, flavor=${AppRuntimeConfig.flavor.name}, isWeb=$_isRunningOnWeb.',
      );
      await initializeLocalTimeZone();

      if (capabilities.canInitializeFirebase) {
        await ref.read(firebaseInitializationProvider.future);
      } else {
        ref
            .read(firebaseAvailabilityProvider.notifier)
            .setUnavailable('Офлайн-версия: облачные функции отключены.');
      }

      final FirebaseAvailabilityState availability = ref.read(
        firebaseAvailabilityProvider,
      );
      final bool firebaseAvailable = availability.isAvailable != false;
      logger.logInfo(
        'AppStartupController: firebaseAvailable=$firebaseAvailable, distribution=${AppRuntimeConfig.distributionMode.name}.',
      );

      if (!capabilities.canRunCloudSync) {
        unawaited(_initializeBackgroundServices());
      } else if (_isRunningOnWeb) {
        if (!firebaseAvailable) {
          state = const AsyncValue<void>.data(null);
          completer.complete();
          return;
        }
        await _initializeWebServices();
      } else {
        if (firebaseAvailable) {
          final FirebaseFirestore firestore = ref.read(firestoreProvider);
          firestore.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        }
        unawaited(_initializeBackgroundServices());
      }
      state = const AsyncValue<void>.data(null);
      completer.complete();
    } catch (error, stackTrace) {
      state = AsyncValue<void>.error(error, stackTrace);
      completer
        ..completeError(error, stackTrace)
        ..future.ignore();
    }
  }

  Future<void> _initializeBackgroundServices() async {
    if (supportsUpcomingPaymentsBackgroundWork()) {
      await ref
          .read(upcomingPaymentsWorkSchedulerProvider)
          .cleanupLegacyWorkIfNeeded();
    }
    unawaited(
      ref
          .read(localSyncIntegrityDebugReporterProvider)
          .runAndLog(context: 'app_startup_background'),
    );
    await _activateUpcomingNotificationsSync();
  }

  Future<void> _initializeWebServices() async {
    try {
      final SyncService syncService = ref.read(syncServiceProvider);
      await syncService.initialize();
      unawaited(
        ref
            .read(localSyncIntegrityDebugReporterProvider)
            .runAndLog(context: 'app_startup_web'),
      );
      // Оптимизация: не ждем завершения первичной синхронизации на вебе,
      // чтобы быстрее показать интерфейс.
      unawaited(syncService.syncPending());

      ref.onDispose(() {
        _webSyncTimer?.cancel();
        _webSyncTimer = null;
      });

      _webSyncTimer?.cancel();
      _webSyncTimer = Timer.periodic(_webSyncInterval, (Timer _) {
        unawaited(syncService.syncPending());
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'app_startup_controller',
          context: ErrorDescription('while warming up web sync services'),
        ),
      );
    }
  }

  Future<void> _activateUpcomingNotificationsSync() async {
    if (!ref.mounted) {
      return;
    }
    try {
      await ref.read(upcomingNotificationsControllerProvider.future);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'app_startup_controller',
          context: ErrorDescription(
            'while starting upcoming notifications coordinator',
          ),
        ),
      );
    }
  }

  bool get _isRunningOnWeb => debugIsWebOverride ?? kIsWeb;
}
