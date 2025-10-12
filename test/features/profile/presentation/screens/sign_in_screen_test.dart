import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  testWidgets('переключение на регистрацию отображает соответствующие поля', (
    WidgetTester tester,
  ) async {
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
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign up'), findsNothing);

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Name (optional)'), findsOneWidget);

    await connectivityStream.close();
  });

  testWidgets('успешная регистрация передает данные в контроллер', (
    WidgetTester tester,
  ) async {
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
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'secret123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name (optional)'),
      'Test User',
    );

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

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
