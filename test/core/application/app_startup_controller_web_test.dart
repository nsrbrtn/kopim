// ignore_for_file: always_specify_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_async/fake_async.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/core/application/app_startup_controller.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/sync/local_sync_integrity_debug_reporter.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';
import 'package:kopim/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart';

class _MockUpcomingPaymentsWorkScheduler extends Mock
    implements UpcomingPaymentsWorkScheduler {}

class _MockSyncService extends Mock implements SyncService {}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockLocalSyncIntegrityDebugReporter extends Mock
    implements LocalSyncIntegrityDebugReporter {}

class _FakeUpcomingNotificationsController
    extends UpcomingNotificationsController {
  _FakeUpcomingNotificationsController({required this.onBuild});

  final VoidCallback onBuild;

  @override
  Future<void> build() async {
    onBuild();
  }
}

class _FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  _FakeFirebaseAppPlatform(super.name, super.options);

  bool _isAutomaticDataCollectionEnabled = true;

  @override
  bool get isAutomaticDataCollectionEnabled =>
      _isAutomaticDataCollectionEnabled;

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    _isAutomaticDataCollectionEnabled = enabled;
  }

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}

class _FakeFirebasePlatform extends FirebasePlatform {
  final Map<String, FirebaseAppPlatform> _apps =
      <String, FirebaseAppPlatform>{};

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList(growable: false);

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final String effectiveName = name ?? defaultFirebaseAppName;
    final FirebaseOptions effectiveOptions =
        options ??
        const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: '1:1:test:test',
          messagingSenderId: '0',
          projectId: 'test-project',
        );
    final FirebaseAppPlatform app = _FakeFirebaseAppPlatform(
      effectiveName,
      effectiveOptions,
    );
    _apps[effectiveName] = app;
    return app;
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    final FirebaseAppPlatform? app = _apps[name];
    if (app == null) {
      throw FirebaseException(
        plugin: 'firebase_core',
        code: 'no-app',
        message: 'App $name is not initialized',
      );
    }
    return app;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel timeZoneChannel = MethodChannel('flutter_timezone');

  setUpAll(() {
    registerFallbackValue(
      const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      ),
    );
  });

  late FirebasePlatform? previousFirebaseDelegate;

  setUp(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    previousFirebaseDelegate = Firebase.delegatePackingProperty;
    Firebase.delegatePackingProperty = _FakeFirebasePlatform();
    AppStartupController.debugIsWebOverride = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timeZoneChannel, (MethodCall call) async {
          if (call.method == 'getLocalTimezone') {
            return 'UTC';
          }
          throw PlatformException(code: 'unimplemented', message: call.method);
        });
  });

  tearDown(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    Firebase.delegatePackingProperty = previousFirebaseDelegate;
    AppStartupController.debugIsWebOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timeZoneChannel, null);
  });

  test('initialize skips Firebase and sync warmup in offline flavor', () async {
    AppRuntimeConfig.configure(AppRuntimeFlavor.offline);
    final _MockUpcomingPaymentsWorkScheduler upcomingScheduler =
        _MockUpcomingPaymentsWorkScheduler();
    final _MockSyncService syncService = _MockSyncService();
    final _MockLocalSyncIntegrityDebugReporter integrityReporter =
        _MockLocalSyncIntegrityDebugReporter();
    int firebaseInitReads = 0;
    int notificationBuilds = 0;

    when(
      () => integrityReporter.runAndLog(context: any(named: 'context')),
    ).thenAnswer((_) async {});
    when(
      () => upcomingScheduler.cleanupLegacyWorkIfNeeded(),
    ).thenAnswer((_) async {});

    final ProviderContainer container = ProviderContainer(
      overrides: [
        firebaseInitializationProvider.overrideWith((ref) async {
          firebaseInitReads++;
          throw StateError('Firebase init must not run in offline flavor');
        }),
        syncServiceProvider.overrideWithValue(syncService),
        upcomingPaymentsWorkSchedulerProvider.overrideWithValue(
          upcomingScheduler,
        ),
        localSyncIntegrityDebugReporterProvider.overrideWithValue(
          integrityReporter,
        ),
        upcomingNotificationsControllerProvider.overrideWith(() {
          return _FakeUpcomingNotificationsController(
            onBuild: () => notificationBuilds++,
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final ProviderSubscription<AppStartupResult> subscription = container
        .listen<AppStartupResult>(
          appStartupControllerProvider,
          // ignore: avoid_unused_parameters
          (previous, next) {},
        );
    addTearDown(subscription.close);

    await container.read(appStartupControllerProvider.notifier).initialize();
    await Future<void>.delayed(Duration.zero);

    expect(firebaseInitReads, 0);
    expect(Firebase.apps, isEmpty);
    expect(container.read(appStartupControllerProvider).isLoading, isFalse);
    expect(notificationBuilds, 1);
    verifyNever(() => syncService.initialize());
    verifyNever(() => syncService.syncPending());
  });

  test(
    'initialize skips background schedulers on web but warms sync service',
    () {
      fakeAsync((FakeAsync async) {
        final _MockUpcomingPaymentsWorkScheduler upcomingScheduler =
            _MockUpcomingPaymentsWorkScheduler();
        final _MockSyncService syncService = _MockSyncService();
        final _MockFirebaseFirestore firestore = _MockFirebaseFirestore();
        int notificationBuilds = 0;
        int syncCallCount = 0;

        when(() => syncService.initialize()).thenAnswer((_) async {});
        when(() => syncService.syncPending()).thenAnswer((_) async {
          syncCallCount++;
        });

        final ProviderContainer container = ProviderContainer(
          overrides: [
            firebaseInitializationProvider.overrideWith((ref) async {
              await Firebase.initializeApp(
                options: const FirebaseOptions(
                  apiKey: 'test-api-key',
                  appId: '1:1:test:test',
                  messagingSenderId: '0',
                  projectId: 'test-project',
                ),
              );
            }),
            upcomingPaymentsWorkSchedulerProvider.overrideWithValue(
              upcomingScheduler,
            ),
            syncServiceProvider.overrideWithValue(syncService),
            firestoreProvider.overrideWithValue(firestore),
            upcomingNotificationsControllerProvider.overrideWith(() {
              return _FakeUpcomingNotificationsController(
                onBuild: () => notificationBuilds++,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final ProviderSubscription<AppStartupResult> subscription = container
            .listen<AppStartupResult>(
              appStartupControllerProvider,
              // ignore: avoid_unused_parameters
              (previous, next) {},
            );
        addTearDown(subscription.close);

        final AppStartupController controller = container.read(
          appStartupControllerProvider.notifier,
        );

        async.run((_) async {
          await controller.initialize();
        });
        async.flushMicrotasks();

        expect(Firebase.apps, isNotEmpty);
        expect(container.read(appStartupControllerProvider).isLoading, isFalse);
        expect(notificationBuilds, 0);
        expect(syncCallCount, 1);

        verify(() => syncService.initialize()).called(1);

        verifyNever(() => upcomingScheduler.scheduleDailyCatchUp());
        verifyNever(() => upcomingScheduler.triggerOneOffCatchUp());

        async.elapse(const Duration(minutes: 2, seconds: 5));
        async.flushMicrotasks();

        expect(syncCallCount, 2);
      });
    },
  );
}
