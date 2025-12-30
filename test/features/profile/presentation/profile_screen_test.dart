import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/screens/menu_screen.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart';
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
  _FakeHomeDashboardPreferencesController();

  @override
  Future<HomeDashboardPreferences> build() async {
    return const HomeDashboardPreferences();
  }
}

class _SignOutSpyAuthController extends AuthController {
  _SignOutSpyAuthController(this._user, this._onSignOut);

  final AuthUser? _user;
  final VoidCallback _onSignOut;

  @override
  FutureOr<AuthUser?> build() => _user;

  @override
  Future<void> signOut() async {
    _onSignOut();
    state = const AsyncValue<AuthUser?>.data(null);
  }
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
    final _MockProfileEventRecorder eventRecorder = _MockProfileEventRecorder();
    when(() => eventRecorder.record(any())).thenAnswer((_) async {});
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
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
          profileControllerProvider(
            signedInUser.uid,
          ).overrideWith(() => _FakeProfileController(hydratedProfile)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          profileEventRecorderProvider.overrideWithValue(eventRecorder),
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
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

    final BuildContext context = tester.element(find.byType(ProfileScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    expect(find.text(strings.profileTitle), findsOneWidget);

    await tester.tap(find.text(strings.profileSectionAccount));
    await tester.pumpAndSettle();

    final TextField nameField = tester
        .widgetList<TextField>(find.byType(TextField))
        .firstWhere(
          (TextField field) => field.controller?.text == hydratedProfile.name,
        );
    expect(nameField.controller?.text, equals('Alice'));

    expect(find.text('EUR'), findsWidgets);
    expect(find.text('EN'), findsWidgets);
  });

  testWidgets('shows sign-in prompt when user is absent', (
    WidgetTester tester,
  ) async {
    final _MockProfileEventRecorder eventRecorder = _MockProfileEventRecorder();
    when(() => eventRecorder.record(any())).thenAnswer((_) async {});
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authControllerProvider.overrideWith(() => _FakeAuthController(null)),
          homeDashboardPreferencesControllerProvider.overrideWith(
            () => _FakeHomeDashboardPreferencesController(),
          ),
          budgetsWithProgressProvider.overrideWith(
            (Ref ref) =>
                const AsyncValue<List<BudgetProgress>>.data(<BudgetProgress>[]),
          ),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          profileEventRecorderProvider.overrideWithValue(eventRecorder),
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
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

  testWidgets('opens general settings from app bar action', (
    WidgetTester tester,
  ) async {
    final _MockProfileEventRecorder eventRecorder = _MockProfileEventRecorder();
    when(() => eventRecorder.record(any())).thenAnswer((_) async {});
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
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
          profileControllerProvider(
            signedInUser.uid,
          ).overrideWith(() => _FakeProfileController(hydratedProfile)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          profileEventRecorderProvider.overrideWithValue(eventRecorder),
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const MenuScreen(),
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(ProfileScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    await tester.tap(find.byTooltip(strings.profileMenuTitle));
    await tester.pumpAndSettle();

    expect(find.byType(MenuScreen), findsOneWidget);
  });

  testWidgets('sign out button triggers auth controller sign out', (
    WidgetTester tester,
  ) async {
    bool didSignOut = false;
    final _MockProfileEventRecorder eventRecorder = _MockProfileEventRecorder();
    when(() => eventRecorder.record(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authControllerProvider.overrideWith(
            () => _SignOutSpyAuthController(
              signedInUser,
              () => didSignOut = true,
            ),
          ),
          homeDashboardPreferencesControllerProvider.overrideWith(
            () => _FakeHomeDashboardPreferencesController(),
          ),
          budgetsWithProgressProvider.overrideWith(
            (Ref ref) =>
                const AsyncValue<List<BudgetProgress>>.data(<BudgetProgress>[]),
          ),
          profileControllerProvider(
            signedInUser.uid,
          ).overrideWith(() => _FakeProfileController(hydratedProfile)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          profileEventRecorderProvider.overrideWithValue(eventRecorder),
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
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

    final BuildContext context = tester.element(find.byType(ProfileScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    await tester.tap(find.text(strings.profileSectionAccount));
    await tester.pumpAndSettle();

    final Finder signOutButton = find.text(strings.profileSignOutCta);

    await tester.ensureVisible(signOutButton);
    await tester.tap(signOutButton, warnIfMissed: false);
    await tester.pump();

    expect(didSignOut, isTrue);
  });
}
