import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/application/firebase_availability.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/utils/timezone_utils.dart';
import 'package:kopim/core/services/recurring_work_scheduler.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_window_service.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';
import 'package:kopim/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart';

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
      await Future.wait(<Future<void>>[
        ref.read(firebaseInitializationProvider.future),
        initializeLocalTimeZone(),
      ]);

      final FirebaseAvailabilityState availability = ref.read(
        firebaseAvailabilityProvider,
      );
      final bool firebaseAvailable = availability.isAvailable != false;
      if (firebaseAvailable) {
        final FirebaseFirestore firestore = ref.read(firestoreProvider);
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }

      if (_isRunningOnWeb) {
        if (!firebaseAvailable) {
          state = const AsyncValue<void>.data(null);
          completer.complete();
          return;
        }
        await _initializeWebServices();
      } else {
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
    await _warmUpRecurringWorkScheduler();
    if (!ref.mounted) {
      return;
    }
    await _warmUpUpcomingPaymentsWork();
    if (!ref.mounted) {
      return;
    }
    await _activateUpcomingNotificationsSync();
  }

  Future<void> _initializeWebServices() async {
    try {
      final SyncService syncService = ref.read(syncServiceProvider);
      await syncService.initialize();
      await syncService.syncPending();

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

  Future<void> _warmUpRecurringWorkScheduler() async {
    try {
      final RecurringWorkScheduler scheduler = ref.read(
        recurringWorkSchedulerProvider,
      );
      final RecurringWindowService recurringWindowService = ref.read(
        recurringWindowServiceProvider,
      );
      await scheduler.initialize();
      await scheduler.scheduleDailyWindowGeneration();
      await scheduler.scheduleMaintenance();
      await scheduler.scheduleApplyRecurringRules();
      if (!ref.mounted) {
        return;
      }
      await recurringWindowService.rebuildWindow();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'app_startup_controller',
          context: ErrorDescription(
            'while warming up background recurring transaction services',
          ),
        ),
      );
    }
  }

  Future<void> _warmUpUpcomingPaymentsWork() async {
    if (!_supportsUpcomingPaymentsWork()) {
      return;
    }
    try {
      final UpcomingPaymentsWorkScheduler scheduler = ref.read(
        upcomingPaymentsWorkSchedulerProvider,
      );
      await scheduler.scheduleDailyCatchUp();
      await scheduler.triggerOneOffCatchUp();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'app_startup_controller',
          context: ErrorDescription('while scheduling upcoming payments work'),
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

  bool _supportsUpcomingPaymentsWork() {
    if (_isRunningOnWeb) {
      return false;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  bool get _isRunningOnWeb => debugIsWebOverride ?? kIsWeb;
}
