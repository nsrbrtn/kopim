import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/application/sync_preferences_provider.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/avatar_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_activity_days_provider.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_management_body.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/presentation/controllers/export_user_data_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/import_user_data_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _AuthControllerStub extends AuthController {
  _AuthControllerStub(this._user);

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

class _AvatarControllerStub extends AvatarController {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);
}

class _OnlineSyncPreferencesControllerStub
    extends OnlineSyncPreferencesController {
  _OnlineSyncPreferencesControllerStub(this._enabled);

  final bool _enabled;

  @override
  Future<bool> build() async => _enabled;
}

class _ExportUserDataControllerStub extends ExportUserDataController {
  @override
  AsyncValue<ExportFileSaveResult?> build() {
    return const AsyncValue<ExportFileSaveResult?>.data(null);
  }
}

class _ImportUserDataControllerStub extends ImportUserDataController {
  @override
  AsyncValue<ImportUserDataResult?> build() {
    return const AsyncValue<ImportUserDataResult?>.data(null);
  }
}

void main() {
  final Profile guestProfile = Profile(
    uid: 'guest-1',
    name: 'Guest',
    currency: ProfileCurrency.rub,
    locale: 'ru',
    photoUrl: null,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
  final ProfileFormParams guestParams = ProfileFormParams(
    uid: guestProfile.uid,
    profile: guestProfile,
  );
  final ProfileFormState guestFormState = ProfileFormState.fromProfile(
    guestProfile.uid,
    guestProfile,
  );
  final Profile registeredProfile = guestProfile.copyWith(uid: 'user-123');
  final ProfileFormParams registeredParams = ProfileFormParams(
    uid: registeredProfile.uid,
    profile: registeredProfile,
  );
  final ProfileFormState registeredFormState = ProfileFormState.fromProfile(
    registeredProfile.uid,
    registeredProfile,
  );
  final UserProgress sampleProgress = UserProgress(
    totalTx: 3,
    level: 1,
    title: 'Новичок',
    nextThreshold: 100,
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  Widget buildTestApp({required List<Override> overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ProfileManagementBody()),
      ),
    );
  }

  testWidgets('анонимный пользователь видит профиль без CTA регистрации', (
    WidgetTester tester,
  ) async {
    final AuthUser guestUser = AuthUser(
      uid: guestProfile.uid,
      isAnonymous: true,
    );

    await tester.pumpWidget(
      buildTestApp(
        overrides: <Override>[
          authControllerProvider.overrideWith(
            () => _AuthControllerStub(guestUser),
          ),
          profileControllerProvider(
            guestProfile.uid,
          ).overrideWith(() => _ProfileControllerStub(guestProfile)),
          profileFormControllerProvider(
            guestParams,
          ).overrideWith(() => _ProfileFormControllerStub(guestFormState)),
          avatarControllerProvider.overrideWith(() => _AvatarControllerStub()),
          userProgressProvider(guestProfile.uid).overrideWith(
            (Ref ref) => Stream<UserProgress>.value(sampleProgress),
          ),
          profileActivityDaysProvider.overrideWith(
            (Ref ref) => Stream<Set<DateTime>>.value(const <DateTime>{}),
          ),
          onlineSyncPreferencesControllerProvider.overrideWith(
            () => _OnlineSyncPreferencesControllerStub(true),
          ),
          exportUserDataControllerProvider.overrideWith(
            () => _ExportUserDataControllerStub(),
          ),
          importUserDataControllerProvider.overrideWith(
            () => _ImportUserDataControllerStub(),
          ),
          levelPolicyProvider.overrideWithValue(const SimpleLevelPolicy()),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    expect(find.text('Register'), findsNothing);
  });

  testWidgets(
    'зарегистрированный пользователь не видит предложение регистрации',
    (WidgetTester tester) async {
      const AuthUser registeredUser = AuthUser(
        uid: 'user-123',
        isAnonymous: false,
      );

      await tester.pumpWidget(
        buildTestApp(
          overrides: <Override>[
            authControllerProvider.overrideWith(
              () => _AuthControllerStub(registeredUser),
            ),
            profileControllerProvider(
              registeredUser.uid,
            ).overrideWith(() => _ProfileControllerStub(registeredProfile)),
            profileFormControllerProvider(registeredParams).overrideWith(
              () => _ProfileFormControllerStub(registeredFormState),
            ),
            avatarControllerProvider.overrideWith(
              () => _AvatarControllerStub(),
            ),
            userProgressProvider(registeredUser.uid).overrideWith(
              (Ref ref) => Stream<UserProgress>.value(sampleProgress),
            ),
            profileActivityDaysProvider.overrideWith(
              (Ref ref) => Stream<Set<DateTime>>.value(const <DateTime>{}),
            ),
            onlineSyncPreferencesControllerProvider.overrideWith(
              () => _OnlineSyncPreferencesControllerStub(true),
            ),
            exportUserDataControllerProvider.overrideWith(
              () => _ExportUserDataControllerStub(),
            ),
            importUserDataControllerProvider.overrideWith(
              () => _ImportUserDataControllerStub(),
            ),
            levelPolicyProvider.overrideWithValue(const SimpleLevelPolicy()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Register'), findsNothing);
      expect(find.byType(Switch), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNotNull);
    },
  );
}
