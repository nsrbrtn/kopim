import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_choice_screen.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_access_status_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_preflight_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_sync_intro_screen.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _FakeDataModeController extends DataModeController {
  _FakeDataModeController(this._state);

  final DataModeState _state;

  @override
  Future<DataModeState> build() async => _state;
}

class _SignedOutAuthController extends AuthController {
  @override
  Future<AuthUser?> build() async => null;
}

class _LoadingAuthController extends AuthController {
  @override
  Future<AuthUser?> build() => Completer<AuthUser?>().future;
}

Widget _buildTestApp({
  CloudActivationPreflightState? state,
  AppCapabilities? capabilities,
  DataModeState? dataModeState,
  bool autoAdvance = false,
  bool fallbackToHome = false,
  AuthController? authController,
  Override? preflightOverride,
  List<Override> extraOverrides = const <Override>[],
}) {
  const DataModeState fallbackDataModeState = DataModeState(
    dataMode: DataMode.localOnly,
    entitlementState: CloudEntitlementState.notActivated,
    migrationDecision: MigrationDecision.none,
  );

  final GoRouter router = GoRouter(
    initialLocation: autoAdvance || fallbackToHome
        ? CloudActivationPreflightScreen.buildRouteLocation(
            autoAdvance: autoAdvance,
            fallbackToHome: fallbackToHome,
          )
        : CloudActivationPreflightScreen.routeName,
    routes: <RouteBase>[
      GoRoute(
        path: CloudActivationPreflightScreen.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final bool autoAdvance =
              state.uri.queryParameters['autoAdvance'] == 'true';
          final bool fallbackToHome =
              state.uri.queryParameters['fallbackToHome'] == 'true';
          return CloudActivationPreflightScreen(
            autoAdvance: autoAdvance,
            fallbackToHome: fallbackToHome,
          );
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Text('home-screen')),
      ),
      GoRoute(
        path: SignInScreen.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Text('sign-in-screen')),
      ),
      GoRoute(
        path: CloudSyncIntroScreen.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Text('intro-screen')),
      ),
      GoRoute(
        path: CloudAccessStatusScreen.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Text('cloud-access-status-screen')),
      ),
      GoRoute(
        path: CloudActivationChoiceScreen.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Text('choice-screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: <Override>[
      if (capabilities != null)
        appCapabilitiesProvider.overrideWithValue(capabilities),
      authControllerProvider.overrideWith(
        () => authController ?? _SignedOutAuthController(),
      ),
      dataModeControllerProvider.overrideWith(
        () => _FakeDataModeController(dataModeState ?? fallbackDataModeState),
      ),
      if (preflightOverride != null)
        preflightOverride
      else
        cloudActivationPreflightProvider.overrideWithValue(state!),
      cloudActivationDecisionProvider.overrideWithValue(
        const CloudActivationDecisionState(
          status: CloudActivationDecisionStatus.blocked,
          title: 'Как включить облачные функции',
          subtitle: 'subtitle',
          body: 'body',
          followupNote: 'note',
          recommendedChoice: null,
          localSnapshotState: CloudActivationSnapshotState.hasData,
          remoteSnapshotState: CloudActivationSnapshotState.unknown,
          localFingerprint: 'local:hasData',
          remoteFingerprint: 'remote:unknown|uid:test',
          options: <CloudActivationDecisionOption>[],
        ),
      ),
      ...extraOverrides,
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('signedOut state opens sign-in route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.signedOut,
        ),
        capabilities: const AppCapabilities(
          canInitializeFirebase: true,
          canUseFirebaseAuth: true,
          canUseFirestore: true,
          canUseRemoteConfig: true,
          canRunCloudSync: true,
          canUseAiTransport: true,
          canShowCloudSyncEntryPoint: true,
          canRegisterInApp: true,
          canShowPaymentOrPurchaseUi: true,
          canActivatePromoOrLicenseInApp: true,
          requiresEntitlementBeforeWebApp: true,
          allowsLocalOnlyUsage: false,
          expiredEntitlementMode: ExpiredEntitlementMode.readOnly,
          firebaseEnvironment: FirebaseEnvironment.dev,
        ),
      ),
    );

    expect(find.text('Нужен вход в аккаунт'), findsOneWidget);

    await tester.tap(find.text('Войти в аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('sign-in-screen'), findsOneWidget);
  });

  testWidgets('production signedOut state opens intro route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.signedOut,
        ),
        capabilities: const AppCapabilities(
          canInitializeFirebase: true,
          canUseFirebaseAuth: true,
          canUseFirestore: true,
          canUseRemoteConfig: true,
          canRunCloudSync: true,
          canUseAiTransport: true,
          canShowCloudSyncEntryPoint: true,
          canRegisterInApp: false,
          canShowPaymentOrPurchaseUi: false,
          canActivatePromoOrLicenseInApp: false,
          requiresEntitlementBeforeWebApp: false,
          allowsLocalOnlyUsage: true,
          expiredEntitlementMode:
              ExpiredEntitlementMode.localWritableSyncPaused,
          firebaseEnvironment: FirebaseEnvironment.prod,
        ),
      ),
    );

    await tester.tap(find.text('Войти в аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('intro-screen'), findsOneWidget);
  });

  testWidgets('alreadyCloudEnabled state explains that preflight is not needed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.alreadyCloudEnabled,
        ),
      ),
    );

    expect(find.text('Синхронизация уже включена'), findsOneWidget);
    expect(
      find.text(
        'Облачные функции уже активны. Дополнительный preflight для этого аккаунта сейчас не требуется.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('blocked state opens choice screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.blockedByLocalOnlyData,
        ),
      ),
    );

    expect(find.text('Нужно действие перед синхронизацией'), findsOneWidget);
    expect(find.text('Выбрать сценарий'), findsOneWidget);

    await tester.tap(find.text('Выбрать сценарий'));
    await tester.pumpAndSettle();

    expect(find.text('choice-screen'), findsOneWidget);
  });

  testWidgets('ready state also opens choice screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.readyForNextStep,
        ),
      ),
    );

    await tester.tap(find.text('Выбрать сценарий'));
    await tester.pumpAndSettle();

    expect(find.text('choice-screen'), findsOneWidget);
  });

  testWidgets('autoAdvance ready state opens choice screen automatically', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.readyForNextStep,
        ),
        autoAdvance: true,
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('choice-screen'), findsOneWidget);
  });

  testWidgets(
    'production entitlementRequired state opens access status route',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          state: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.entitlementRequired,
          ),
          capabilities: const AppCapabilities(
            canInitializeFirebase: true,
            canUseFirebaseAuth: true,
            canUseFirestore: true,
            canUseRemoteConfig: true,
            canRunCloudSync: true,
            canUseAiTransport: true,
            canShowCloudSyncEntryPoint: true,
            canRegisterInApp: false,
            canShowPaymentOrPurchaseUi: false,
            canActivatePromoOrLicenseInApp: false,
            requiresEntitlementBeforeWebApp: false,
            allowsLocalOnlyUsage: true,
            expiredEntitlementMode:
                ExpiredEntitlementMode.localWritableSyncPaused,
            firebaseEnvironment: FirebaseEnvironment.prod,
          ),
        ),
      );

      expect(find.text('Доступ не активен'), findsOneWidget);

      await tester.tap(find.text('Проверить доступ снова'));
      await tester.pumpAndSettle();

      expect(find.text('cloud-access-status-screen'), findsOneWidget);
    },
  );

  testWidgets(
    'autoAdvance entitlementRequired state opens access status automatically in production',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          state: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.entitlementRequired,
          ),
          autoAdvance: true,
          capabilities: const AppCapabilities(
            canInitializeFirebase: true,
            canUseFirebaseAuth: true,
            canUseFirestore: true,
            canUseRemoteConfig: true,
            canRunCloudSync: true,
            canUseAiTransport: true,
            canShowCloudSyncEntryPoint: true,
            canRegisterInApp: false,
            canShowPaymentOrPurchaseUi: false,
            canActivatePromoOrLicenseInApp: false,
            requiresEntitlementBeforeWebApp: false,
            allowsLocalOnlyUsage: true,
            expiredEntitlementMode:
                ExpiredEntitlementMode.localWritableSyncPaused,
            firebaseEnvironment: FirebaseEnvironment.prod,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('cloud-access-status-screen'), findsOneWidget);
    },
  );

  testWidgets(
    'autoAdvance waits through signedOut loading state and opens choice after preflight refresh',
    (WidgetTester tester) async {
      final StreamController<CloudActivationPreflightState>
      preflightController =
          StreamController<CloudActivationPreflightState>.broadcast();
      final StreamProvider<CloudActivationPreflightState>
      preflightStateProvider = StreamProvider<CloudActivationPreflightState>((
        Ref _,
      ) {
        return preflightController.stream;
      });
      addTearDown(preflightController.close);

      await tester.pumpWidget(
        _buildTestApp(
          autoAdvance: true,
          authController: _LoadingAuthController(),
          preflightOverride: cloudActivationPreflightProvider.overrideWith((
            Ref ref,
          ) {
            return ref
                .watch(preflightStateProvider)
                .maybeWhen(
                  data: (CloudActivationPreflightState value) => value,
                  orElse: () => const CloudActivationPreflightState(
                    CloudActivationPreflightStatus.signedOut,
                  ),
                );
          }),
        ),
      );

      await tester.pump();
      expect(find.text('Проверяем состояние подключения'), findsOneWidget);

      preflightController.add(
        const CloudActivationPreflightState(
          CloudActivationPreflightStatus.readyForNextStep,
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('choice-screen'), findsOneWidget);
    },
  );

  testWidgets(
    'autoAdvance with fallbackToHome returns to home when no cloud action is required',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          state: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.alreadyCloudEnabled,
          ),
          autoAdvance: true,
          fallbackToHome: true,
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('home-screen'), findsOneWidget);
    },
  );

  testWidgets(
    'production entitlementRequired state shows expired copy when access expired',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          state: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.entitlementRequired,
          ),
          capabilities: const AppCapabilities(
            canInitializeFirebase: true,
            canUseFirebaseAuth: true,
            canUseFirestore: true,
            canUseRemoteConfig: true,
            canRunCloudSync: true,
            canUseAiTransport: true,
            canShowCloudSyncEntryPoint: true,
            canRegisterInApp: false,
            canShowPaymentOrPurchaseUi: false,
            canActivatePromoOrLicenseInApp: false,
            requiresEntitlementBeforeWebApp: false,
            allowsLocalOnlyUsage: true,
            expiredEntitlementMode:
                ExpiredEntitlementMode.localWritableSyncPaused,
            firebaseEnvironment: FirebaseEnvironment.prod,
          ),
          dataModeState: const DataModeState(
            dataMode: DataMode.localOnly,
            entitlementState: CloudEntitlementState.expired,
            migrationDecision: MigrationDecision.none,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Срок доступа истек'), findsOneWidget);
      expect(
        find.text(
          'Срок облачного доступа для текущего аккаунта истек. Синхронизация остается на паузе, пока статус доступа не будет обновлен. До этого можно продолжать работать локально.',
        ),
        findsOneWidget,
      );
    },
  );
}
