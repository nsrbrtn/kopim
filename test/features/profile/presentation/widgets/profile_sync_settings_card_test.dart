import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_access_status_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_preflight_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_sync_intro_screen.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_sync_settings_card.dart';
import 'package:go_router/go_router.dart';
import '../router_test_helper.dart';

class _FakeDataModeController extends DataModeController {
  _FakeDataModeController(this._state);

  final DataModeState _state;

  @override
  Future<DataModeState> build() async => _state;
}

void main() {
  setUp(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
  });

  testWidgets('preflight CTA opens preflight screen and then sign-in route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appCapabilitiesProvider.overrideWithValue(
            const AppCapabilities(
              canInitializeFirebase: true,
              canUseFirebaseAuth: true,
              canUseFirestore: true,
              canUseRemoteConfig: true,
              canRunCloudSync: true,
              canUseAiTransport: true,
              firebaseEnvironment: FirebaseEnvironment.dev,
              allowsLocalOnlyUsage: true,
              canActivatePromoOrLicenseInApp: true,
              canRegisterInApp: true,
              canShowCloudSyncEntryPoint: true,
              canShowPaymentOrPurchaseUi: true,
              expiredEntitlementMode: ExpiredEntitlementMode.none,
              requiresEntitlementBeforeWebApp: false,
            ),
          ),
          dataModeControllerProvider.overrideWith(
            () => _FakeDataModeController(
              const DataModeState(
                dataMode: DataMode.localOnly,
                entitlementState: CloudEntitlementState.active,
                migrationDecision: MigrationDecision.none,
              ),
            ),
          ),
          // Stub featureAccessProvider to avoid reaching firebaseAuth in tests.
          // requiresSignIn shows "Продолжить подключение" CTA without reaching cloudAuthRepository.
          featureAccessProvider.overrideWithValue(
            const FeatureAccess(
              entitlementState: EntitlementAccessState.cloudActive,
              cloudSync: FeatureGate(FeatureAccessStatus.requiresSignIn),
              webApp: FeatureGate(FeatureAccessStatus.enabled),
              aiAssistant: FeatureGate(FeatureAccessStatus.disabledByBuild),
              advancedAnalytics: FeatureGate(
                FeatureAccessStatus.disabledByBuild,
              ),
              isWebReadOnly: false,
            ),
          ),
        ],
        child: buildTestAppWithRouter(
          child: const Scaffold(body: ProfileSyncSettingsCard()),
          additionalRoutes: <RouteBase>[
            GoRoute(
              path: CloudActivationPreflightScreen.routeName,
              builder: (BuildContext context, GoRouterState state) =>
                  ProviderScope(
                    overrides: <Override>[
                      cloudActivationPreflightProvider.overrideWithValue(
                        const CloudActivationPreflightState(
                          CloudActivationPreflightStatus.signedOut,
                        ),
                      ),
                    ],
                    child: const CloudActivationPreflightScreen(),
                  ),
            ),
            mockRoute(CloudSyncIntroScreen.routeName, text: 'intro-screen'),
            mockRoute(SignInScreen.routeName, text: 'sign-in-screen'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Продолжить подключение'));
    await tester.pumpAndSettle();

    expect(find.text('Подключение облака'), findsOneWidget);

    await tester.tap(find.text('Войти в аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('sign-in-screen'), findsOneWidget);
  });

  testWidgets('production requiresSignIn CTA opens intro screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appCapabilitiesProvider.overrideWithValue(
            const AppCapabilities(
              canInitializeFirebase: true,
              canUseFirebaseAuth: true,
              canUseFirestore: true,
              canUseRemoteConfig: true,
              canRunCloudSync: true,
              canUseAiTransport: true,
              firebaseEnvironment: FirebaseEnvironment.prod,
              allowsLocalOnlyUsage: true,
              canActivatePromoOrLicenseInApp: false,
              canRegisterInApp: false,
              canShowCloudSyncEntryPoint: true,
              canShowPaymentOrPurchaseUi: false,
              expiredEntitlementMode:
                  ExpiredEntitlementMode.localWritableSyncPaused,
              requiresEntitlementBeforeWebApp: false,
            ),
          ),
          dataModeControllerProvider.overrideWith(
            () => _FakeDataModeController(
              const DataModeState(
                dataMode: DataMode.localOnly,
                entitlementState: CloudEntitlementState.active,
                migrationDecision: MigrationDecision.none,
              ),
            ),
          ),
          featureAccessProvider.overrideWithValue(
            const FeatureAccess(
              entitlementState: EntitlementAccessState.cloudActive,
              cloudSync: FeatureGate(FeatureAccessStatus.requiresSignIn),
              webApp: FeatureGate(FeatureAccessStatus.enabled),
              aiAssistant: FeatureGate(FeatureAccessStatus.disabledByBuild),
              advancedAnalytics: FeatureGate(
                FeatureAccessStatus.disabledByBuild,
              ),
              isWebReadOnly: false,
            ),
          ),
        ],
        child: buildTestAppWithRouter(
          child: const Scaffold(body: ProfileSyncSettingsCard()),
          additionalRoutes: <RouteBase>[
            mockRoute(CloudSyncIntroScreen.routeName, text: 'intro-screen'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Включить синхронизацию'));
    await tester.pumpAndSettle();

    expect(find.text('intro-screen'), findsOneWidget);
  });

  testWidgets('production requiresEntitlement CTA opens access status screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appCapabilitiesProvider.overrideWithValue(
            const AppCapabilities(
              canInitializeFirebase: true,
              canUseFirebaseAuth: true,
              canUseFirestore: true,
              canUseRemoteConfig: true,
              canRunCloudSync: true,
              canUseAiTransport: true,
              firebaseEnvironment: FirebaseEnvironment.prod,
              allowsLocalOnlyUsage: true,
              canActivatePromoOrLicenseInApp: false,
              canRegisterInApp: false,
              canShowCloudSyncEntryPoint: true,
              canShowPaymentOrPurchaseUi: false,
              expiredEntitlementMode:
                  ExpiredEntitlementMode.localWritableSyncPaused,
              requiresEntitlementBeforeWebApp: false,
            ),
          ),
          dataModeControllerProvider.overrideWith(
            () => _FakeDataModeController(
              const DataModeState(
                dataMode: DataMode.localOnly,
                entitlementState: CloudEntitlementState.notActivated,
                migrationDecision: MigrationDecision.none,
              ),
            ),
          ),
          featureAccessProvider.overrideWithValue(
            const FeatureAccess(
              entitlementState: EntitlementAccessState.freeLocal,
              cloudSync: FeatureGate(FeatureAccessStatus.requiresEntitlement),
              webApp: FeatureGate(FeatureAccessStatus.requiresEntitlement),
              aiAssistant: FeatureGate(FeatureAccessStatus.disabledByBuild),
              advancedAnalytics: FeatureGate(
                FeatureAccessStatus.disabledByBuild,
              ),
              isWebReadOnly: false,
            ),
          ),
        ],
        child: buildTestAppWithRouter(
          child: const Scaffold(body: ProfileSyncSettingsCard()),
          additionalRoutes: <RouteBase>[
            mockRoute(
              CloudAccessStatusScreen.routeName,
              text: 'cloud-access-status',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Доступ не активен'), findsOneWidget);
    expect(
      find.text(
        'Для текущего аккаунта пока не найден активный доступ к облачным функциям.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Проверить доступ снова'));
    await tester.pumpAndSettle();

    expect(find.text('cloud-access-status'), findsOneWidget);
  });

  testWidgets('production expired entitlement shows paused copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appCapabilitiesProvider.overrideWithValue(
            const AppCapabilities(
              canInitializeFirebase: true,
              canUseFirebaseAuth: true,
              canUseFirestore: true,
              canUseRemoteConfig: true,
              canRunCloudSync: true,
              canUseAiTransport: true,
              firebaseEnvironment: FirebaseEnvironment.prod,
              allowsLocalOnlyUsage: true,
              canActivatePromoOrLicenseInApp: false,
              canRegisterInApp: false,
              canShowCloudSyncEntryPoint: true,
              canShowPaymentOrPurchaseUi: false,
              expiredEntitlementMode:
                  ExpiredEntitlementMode.localWritableSyncPaused,
              requiresEntitlementBeforeWebApp: false,
            ),
          ),
          dataModeControllerProvider.overrideWith(
            () => _FakeDataModeController(
              const DataModeState(
                dataMode: DataMode.localOnly,
                entitlementState: CloudEntitlementState.expired,
                migrationDecision: MigrationDecision.none,
              ),
            ),
          ),
          featureAccessProvider.overrideWithValue(
            const FeatureAccess(
              entitlementState: EntitlementAccessState.cloudExpired,
              cloudSync: FeatureGate(FeatureAccessStatus.requiresEntitlement),
              webApp: FeatureGate(FeatureAccessStatus.requiresEntitlement),
              aiAssistant: FeatureGate(FeatureAccessStatus.disabledByBuild),
              advancedAnalytics: FeatureGate(
                FeatureAccessStatus.disabledByBuild,
              ),
              isWebReadOnly: false,
            ),
          ),
        ],
        child: buildTestAppWithRouter(
          child: const Scaffold(body: ProfileSyncSettingsCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Срок доступа истек'), findsOneWidget);
    expect(
      find.text(
        'Срок облачного доступа для текущего аккаунта истек. Синхронизация остается на паузе, пока статус доступа не будет обновлен.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('production requiresSignIn copy stays neutral', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appCapabilitiesProvider.overrideWithValue(
            const AppCapabilities(
              canInitializeFirebase: true,
              canUseFirebaseAuth: true,
              canUseFirestore: true,
              canUseRemoteConfig: true,
              canRunCloudSync: true,
              canUseAiTransport: true,
              firebaseEnvironment: FirebaseEnvironment.prod,
              allowsLocalOnlyUsage: true,
              canActivatePromoOrLicenseInApp: false,
              canRegisterInApp: false,
              canShowCloudSyncEntryPoint: true,
              canShowPaymentOrPurchaseUi: false,
              expiredEntitlementMode:
                  ExpiredEntitlementMode.localWritableSyncPaused,
              requiresEntitlementBeforeWebApp: false,
            ),
          ),
          dataModeControllerProvider.overrideWith(
            () => _FakeDataModeController(
              const DataModeState(
                dataMode: DataMode.localOnly,
                entitlementState: CloudEntitlementState.active,
                migrationDecision: MigrationDecision.none,
              ),
            ),
          ),
          featureAccessProvider.overrideWithValue(
            const FeatureAccess(
              entitlementState: EntitlementAccessState.cloudActive,
              cloudSync: FeatureGate(FeatureAccessStatus.requiresSignIn),
              webApp: FeatureGate(FeatureAccessStatus.enabled),
              aiAssistant: FeatureGate(FeatureAccessStatus.disabledByBuild),
              advancedAnalytics: FeatureGate(
                FeatureAccessStatus.disabledByBuild,
              ),
              isWebReadOnly: false,
            ),
          ),
        ],
        child: buildTestAppWithRouter(
          child: const Scaffold(body: ProfileSyncSettingsCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Нужен вход в аккаунт'), findsOneWidget);
    expect(find.textContaining('Лицензионный ключ'), findsNothing);
  });
}
