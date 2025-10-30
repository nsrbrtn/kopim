import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/services/recurring_work_scheduler.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';
import 'package:kopim/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart';

part 'app_startup_controller.g.dart';

typedef AppStartupResult = AsyncValue<void>;

@riverpod
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
      await ref.read(firebaseInitializationProvider.future);

      final FirebaseFirestore firestore = ref.read(firestoreProvider);
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      if (_isRunningOnWeb) {
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
    await _warmUpUpcomingPaymentsWork();
    await _activateUpcomingNotificationsSync();
  }

  Future<void> _initializeWebServices() async {
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
  }

  Future<void> _warmUpRecurringWorkScheduler() async {
    try {
      final RecurringWorkScheduler scheduler = ref.read(
        recurringWorkSchedulerProvider,
      );
      await scheduler.initialize();
      await scheduler.scheduleDailyWindowGeneration();
      await scheduler.scheduleMaintenance();
      await scheduler.scheduleApplyRecurringRules();
      await ref.read(recurringWindowServiceProvider).rebuildWindow();
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
