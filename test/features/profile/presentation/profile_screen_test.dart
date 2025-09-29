import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _StubUpdateProfileUseCase implements UpdateProfileUseCase {
  @override
  Future<Profile> call(Profile profile) async => profile;
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  FutureOr<AuthUser?> build() => _user;
}

class _FakeProfileController extends ProfileController {
  _FakeProfileController(this._profile);

  final Profile? _profile;

  @override
  FutureOr<Profile?> build(String uid) => _profile;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const AuthUser signedInUser = AuthUser(
    uid: 'user-42',
    email: 'user@example.com',
    isAnonymous: false,
    emailVerified: true,
  );

  final Profile hydratedProfile = Profile(
    uid: signedInUser.uid,
    name: 'Alice',
    currency: ProfileCurrency.eur,
    locale: 'en',
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  testWidgets('renders hydrated profile form with initial values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(
            () => _FakeAuthController(signedInUser),
          ),
          profileControllerProvider(
            signedInUser.uid,
          ).overrideWith(() => _FakeProfileController(hydratedProfile)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);

    final TextFormField nameField = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );
    expect(nameField.initialValue, equals('Alice'));

    expect(find.text('EUR'), findsWidgets);
    expect(find.text('EN'), findsWidgets);
  });

  testWidgets('shows sign-in prompt when user is absent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(() => _FakeAuthController(null)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Please sign in to manage your profile.'), findsOneWidget);
  });
}
