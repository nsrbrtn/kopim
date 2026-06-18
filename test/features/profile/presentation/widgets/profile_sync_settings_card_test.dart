import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_sync_settings_card.dart';

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

  testWidgets('sign-in CTA opens SignInScreen.routeName', (
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
        ],
        child: MaterialApp(
          routes: <String, WidgetBuilder>{
            SignInScreen.routeName: (_) =>
                const Scaffold(body: Text('sign-in-screen')),
          },
          home: const Scaffold(body: ProfileSyncSettingsCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Войти в аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('sign-in-screen'), findsOneWidget);
  });
}
