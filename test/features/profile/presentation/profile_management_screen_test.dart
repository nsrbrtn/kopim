import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/application/sync_preferences_provider.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/avatar_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_activity_days_provider.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _StubUpdateProfileUseCase implements UpdateProfileUseCase {
  @override
  Future<ProfileCommandResult<Profile>> call(Profile profile) async {
    return ProfileCommandResult<Profile>(
      value: profile,
      events: <ProfileDomainEvent>[
        ProfileDomainEvent.profileUpdated(profile: profile),
      ],
    );
  }
}

class _MockProfileEventRecorder extends Mock implements ProfileEventRecorder {}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  FutureOr<AuthUser?> build() => _user;
}

class _FakeHomeDashboardPreferencesController
    extends HomeDashboardPreferencesController {
  @override
  Future<HomeDashboardPreferences> build() async {
    return const HomeDashboardPreferences();
  }
}

class _FakeOnlineSyncPreferencesController
    extends OnlineSyncPreferencesController {
  @override
  Future<bool> build() async => true;
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
    locale: 'ru',
    updatedAt: DateTime.utc(2024, 1, 1),
  );
  final UserProgress defaultProgress = UserProgress(
    title: 'Новичок',
    nextThreshold: 10,
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  List<Override> buildOverrides() {
    final _MockProfileEventRecorder eventRecorder = _MockProfileEventRecorder();
    when(() => eventRecorder.record(any())).thenAnswer((_) async {});

    return <Override>[
      authControllerProvider.overrideWith(
        () => _FakeAuthController(signedInUser),
      ),
      homeDashboardPreferencesControllerProvider.overrideWith(
        () => _FakeHomeDashboardPreferencesController(),
      ),
      budgetsWithProgressProvider.overrideWith(
        (Ref ref) =>
            const AsyncValue<List<BudgetProgress>>.data(<BudgetProgress>[]),
      ),
      avatarControllerProvider.overrideWithValue(
        const AsyncValue<void>.data(null),
      ),
      profileControllerProvider(
        signedInUser.uid,
      ).overrideWith(() => _FakeProfileController(hydratedProfile)),
      userProgressProvider(
        signedInUser.uid,
      ).overrideWith((Ref ref) => Stream<UserProgress>.value(defaultProgress)),
      updateProfileUseCaseProvider.overrideWith(
        (Ref ref) => _StubUpdateProfileUseCase(),
      ),
      profileEventRecorderProvider.overrideWithValue(eventRecorder),
      onlineSyncPreferencesControllerProvider.overrideWith(
        () => _FakeOnlineSyncPreferencesController(),
      ),
      profileActivityDaysProvider.overrideWith(
        (Ref ref) => Stream<Set<DateTime>>.value(const <DateTime>{}),
      ),
      manageCategoryTreeProvider.overrideWith(
        (Ref ref) =>
            Stream<List<CategoryTreeNode>>.value(const <CategoryTreeNode>[]),
      ),
    ];
  }

  testWidgets('shows app bar back button when opened as secondary route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildOverrides(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            ProfileManagementScreen.routeName: (_) =>
                const ProfileManagementScreen(),
          },
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(ProfileManagementScreen.routeName),
                    child: const Text('open-profile'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-profile'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileManagementScreen), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileManagementScreen), findsNothing);
    expect(find.text('open-profile'), findsOneWidget);
  });
}
