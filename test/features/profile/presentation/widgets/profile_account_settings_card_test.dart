import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_account_settings_card.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _DeleteAccountSpyAuthController extends AuthController {
  _DeleteAccountSpyAuthController(this._user);

  final AuthUser _user;

  @override
  FutureOr<AuthUser?> build() => _user;
}

class _ProfileControllerStub extends ProfileController {
  _ProfileControllerStub(this._profile);

  final Profile? _profile;

  @override
  FutureOr<Profile?> build(String uid) => _profile;
}

class _ProfileFormControllerStub extends ProfileFormController {
  _ProfileFormControllerStub(this._state);

  final ProfileFormState _state;

  @override
  ProfileFormState build(ProfileFormParams params) => _state;
}

void main() {
  testWidgets('удаление аккаунта требует кодовое слово и пароль', (
    WidgetTester tester,
  ) async {
    const AuthUser user = AuthUser(
      uid: 'user-123',
      email: 'user@example.com',
      isAnonymous: false,
    );
    final Profile profile = Profile(
      uid: user.uid,
      name: 'Tester',
      updatedAt: DateTime.utc(2024, 1, 1),
    );
    final ProfileFormParams params = ProfileFormParams(
      uid: profile.uid,
      profile: profile,
    );
    final ProfileFormState formState = ProfileFormState.fromProfile(
      profile.uid,
      profile,
    );
    final _DeleteAccountSpyAuthController authController =
        _DeleteAccountSpyAuthController(user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authControllerProvider.overrideWith(() => authController),
          profileControllerProvider(
            user.uid,
          ).overrideWith(() => _ProfileControllerStub(profile)),
          profileFormControllerProvider(
            params,
          ).overrideWith(() => _ProfileFormControllerStub(formState)),
        ],
        child: const MaterialApp(
          locale: Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ProfileAccountSettingsCard()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Удалить аккаунт'), findsOneWidget);

    await tester.tap(find.text('Удалить аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('Удалить аккаунт?'), findsOneWidget);

    FilledButton deleteButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Удалить навсегда'),
    );
    expect(deleteButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(1), 'УДАЛИТЬ');
    await tester.enterText(find.byType(TextField).at(2), 'secret123');
    await tester.pumpAndSettle();

    deleteButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Удалить навсегда'),
    );
    expect(deleteButton.onPressed, isNotNull);
  });
}
