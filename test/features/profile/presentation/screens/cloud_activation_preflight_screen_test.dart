import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_choice_screen.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_access_status_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_preflight_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_sync_intro_screen.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:go_router/go_router.dart';
import '../router_test_helper.dart';

class _FakeDataModeController extends DataModeController {
  _FakeDataModeController(this._state);

  final DataModeState _state;

  @override
  Future<DataModeState> build() async => _state;
}

Widget _buildTestApp({
  required CloudActivationPreflightState state,
  AppCapabilities? capabilities,
  DataModeState? dataModeState,
}) {
  const DataModeState fallbackDataModeState = DataModeState(
    dataMode: DataMode.localOnly,
    entitlementState: CloudEntitlementState.notActivated,
    migrationDecision: MigrationDecision.none,
  );

  return ProviderScope(
    overrides: <Override>[
      if (capabilities != null)
        appCapabilitiesProvider.overrideWithValue(capabilities),
      dataModeControllerProvider.overrideWith(
        () => _FakeDataModeController(dataModeState ?? fallbackDataModeState),
      ),
      cloudActivationPreflightProvider.overrideWithValue(state),
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
    ],
    child: buildTestAppWithRouter(
      child: const CloudActivationPreflightScreen(),
      initialLocation: '/cloud-activation-preflight',
      additionalRoutes: <RouteBase>[
        mockRoute(SignInScreen.routeName, text: 'sign-in-screen'),
        mockRoute(CloudSyncIntroScreen.routeName, text: 'intro-screen'),
        mockRoute(
          CloudAccessStatusScreen.routeName,
          text: 'cloud-access-status-screen',
        ),
        mockRoute(CloudActivationChoiceScreen.routeName, text: 'choice-screen'),
      ],
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
