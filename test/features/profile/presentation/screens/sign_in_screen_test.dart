import 'dart:async';

import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kopim/features/profile/domain/entities/cloud_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

class _StubAuthController extends AuthController {
  SignInRequest? signInRequest;
  SignUpRequest? signUpRequest;
  bool offlineModeRequested = false;

  @override
  Future<AuthUser?> build() async => null;

  @override
  Future<void> signIn(SignInRequest request) async {
    signInRequest = request;
  }

  @override
  Future<void> signUp(SignUpRequest request) async {
    signUpRequest = request;
  }

  @override
  Future<void> continueWithOfflineMode() async {
    offlineModeRequested = true;
  }
}

void main() {
  setUp(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
  });

  tearDown(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
  });

  Future<void> pumpReady(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> setWindowSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('переключение на регистрацию отображает соответствующие поля', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(800, 1200));
    final _MockConnectivity connectivity = _MockConnectivity();
    final StreamController<List<ConnectivityResult>> connectivityStream =
        StreamController<List<ConnectivityResult>>.broadcast();
    when(() => connectivity.checkConnectivity()).thenAnswer(
      (_) async => const <ConnectivityResult>[ConnectivityResult.wifi],
    );
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityStream.stream);
    final _StubAuthController authController = _StubAuthController();

    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          connectivityProvider.overrideWithValue(connectivity),
          authControllerProvider.overrideWith(() => authController),
          dataModeControllerProvider.overrideWith(
            () => _FakeDataModeController(
              const DataModeState(
                dataMode: DataMode.cloudEnabled,
                entitlementState: CloudEntitlementState.active,
                migrationDecision: MigrationDecision.none,
                cloudDataState: CloudDataState.active,
                requiresFreshCloudUpload: false,
                isSyncBlockedByCloudState: false,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInScreen(),
        ),
      ),
    );

    await pumpReady(tester);

    final BuildContext context = tester.element(find.byType(SignInScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('Создать'), findsNothing);

    final Finder toggleToSignUp = find.text('Создать аккаунт');
    await tester.ensureVisible(toggleToSignUp);
    await tester.tap(toggleToSignUp);
    await pumpReady(tester);

    expect(find.text('Создать'), findsOneWidget);
    expect(find.text(strings.signUpConfirmPasswordLabel), findsOneWidget);
    expect(find.text(strings.signUpDisplayNameLabel), findsOneWidget);

    await connectivityStream.close();
  });

  testWidgets(
    'SignInScreen запускается в режиме регистрации при startInSignUpMode',
    (WidgetTester tester) async {
      await setWindowSize(tester, const Size(800, 1200));
      final _MockConnectivity connectivity = _MockConnectivity();
      final StreamController<List<ConnectivityResult>> connectivityStream =
          StreamController<List<ConnectivityResult>>.broadcast();
      when(() => connectivity.checkConnectivity()).thenAnswer(
        (_) async => const <ConnectivityResult>[ConnectivityResult.wifi],
      );
      when(
        () => connectivity.onConnectivityChanged,
      ).thenAnswer((_) => connectivityStream.stream);
      final _StubAuthController authController = _StubAuthController();

      await tester.pumpWidget(
        ProviderScope(
          // ignore: always_specify_types
          overrides: [
            connectivityProvider.overrideWithValue(connectivity),
            authControllerProvider.overrideWith(() => authController),
            dataModeControllerProvider.overrideWith(
              () => _FakeDataModeController(
                const DataModeState(
                  dataMode: DataMode.cloudEnabled,
                  entitlementState: CloudEntitlementState.active,
                  migrationDecision: MigrationDecision.none,
                  cloudDataState: CloudDataState.active,
                  requiresFreshCloudUpload: false,
                  isSyncBlockedByCloudState: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SignInScreen(startInSignUpMode: true),
          ),
        ),
      );

      await pumpReady(tester);

      final BuildContext context = tester.element(find.byType(SignInScreen));
      final AppLocalizations strings = AppLocalizations.of(context)!;

      expect(find.text('Создать'), findsOneWidget);
      expect(find.text(strings.signUpConfirmPasswordLabel), findsOneWidget);
      expect(find.text(strings.signUpDisplayNameLabel), findsOneWidget);

      await connectivityStream.close();
    },
  );

  testWidgets('успешная регистрация передает данные в контроллер', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(800, 1200));
    final _MockConnectivity connectivity = _MockConnectivity();
    final StreamController<List<ConnectivityResult>> connectivityStream =
        StreamController<List<ConnectivityResult>>.broadcast();
    when(() => connectivity.checkConnectivity()).thenAnswer(
      (_) async => const <ConnectivityResult>[ConnectivityResult.wifi],
    );
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityStream.stream);
    final _StubAuthController authController = _StubAuthController();

    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          connectivityProvider.overrideWithValue(connectivity),
          authControllerProvider.overrideWith(() => authController),
          dataModeControllerProvider.overrideWith(
            () => _FakeDataModeController(
              const DataModeState(
                dataMode: DataMode.cloudEnabled,
                entitlementState: CloudEntitlementState.active,
                migrationDecision: MigrationDecision.none,
                cloudDataState: CloudDataState.active,
                requiresFreshCloudUpload: false,
                isSyncBlockedByCloudState: false,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInScreen(),
        ),
      ),
    );

    await pumpReady(tester);

    final Finder toggleToSignUp = find.text('Создать аккаунт');
    await tester.ensureVisible(toggleToSignUp);
    await tester.tap(toggleToSignUp);
    await pumpReady(tester);

    final Finder textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(4));
    await tester.enterText(textFields.at(0), 'user@example.com');
    await tester.enterText(textFields.at(1), 'secret123');
    await tester.enterText(textFields.at(2), 'secret123');
    await tester.enterText(textFields.at(3), 'Test User');

    await tester.pump();

    final Finder signUpSubmit = find.text('Создать');
    await tester.ensureVisible(signUpSubmit);
    await tester.tap(signUpSubmit);
    await pumpReady(tester);

    expect(
      authController.signUpRequest,
      const SignUpRequest.email(
        email: 'user@example.com',
        password: 'secret123',
        displayName: 'Test User',
      ),
    );

    await connectivityStream.close();
  });
}

class _FakeDataModeController extends DataModeController {
  _FakeDataModeController(this._state);
  final DataModeState _state;

  @override
  FutureOr<DataModeState> build() => _state;
}
