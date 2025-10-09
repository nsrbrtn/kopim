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
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_job.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
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

class _StubRecurringTransactionsRepository
    implements RecurringTransactionsRepository {
  const _StubRecurringTransactionsRepository();

  @override
  Future<void> deleteRule(String id) => throw UnimplementedError();

  @override
  Future<void> enqueueJob({
    required String type,
    required String payload,
    required DateTime runAt,
  }) => throw UnimplementedError();

  @override
  Future<List<RecurringRule>> getAllRules({bool activeOnly = false}) =>
      Future<List<RecurringRule>>.value(const <RecurringRule>[]);

  @override
  Future<List<RecurringOccurrence>> getDueOccurrences(DateTime forDate) =>
      Future<List<RecurringOccurrence>>.value(const <RecurringOccurrence>[]);

  @override
  Future<RecurringRule?> getRuleById(String id) =>
      Future<RecurringRule?>.value(null);

  @override
  Future<bool> applyRuleOccurrence({
    required RecurringRule rule,
    required String occurrenceId,
    required DateTime occurrenceLocalDate,
    required Future<String?> Function() postTransaction,
  }) => Future<bool>.value(false);

  @override
  Future<void> markJobAttempt(int jobId, {String? error}) =>
      throw UnimplementedError();

  @override
  Future<void> saveOccurrences(
    Iterable<RecurringOccurrence> occurrences, {
    bool replaceExisting = false,
  }) => throw UnimplementedError();

  @override
  Future<void> toggleRule({required String id, required bool isActive}) =>
      throw UnimplementedError();

  @override
  Future<void> upsertRule(RecurringRule rule, {bool regenerateWindow = true}) =>
      throw UnimplementedError();

  @override
  Future<void> updateOccurrenceStatus(
    String occurrenceId,
    RecurringOccurrenceStatus status, {
    String? postedTxId,
  }) => throw UnimplementedError();

  @override
  Stream<List<RecurringJob>> watchPendingJobs() =>
      Stream<List<RecurringJob>>.value(const <RecurringJob>[]);

  @override
  Stream<List<RecurringOccurrence>> watchRuleOccurrences(String ruleId) =>
      Stream<List<RecurringOccurrence>>.value(const <RecurringOccurrence>[]);

  @override
  Stream<List<RecurringRule>> watchRules() =>
      Stream<List<RecurringRule>>.value(const <RecurringRule>[]);

  @override
  Stream<List<RecurringOccurrence>> watchUpcomingOccurrences({
    required DateTime from,
    required DateTime to,
  }) => Stream<List<RecurringOccurrence>>.value(const <RecurringOccurrence>[]);
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
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
          recurringTransactionsRepositoryProvider.overrideWithValue(
            const _StubRecurringTransactionsRepository(),
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
    expect(find.text('Account'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    final TextFormField nameField = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );
    expect(nameField.initialValue, equals('Alice'));

    expect(find.text('EUR'), findsWidgets);
    expect(find.text('EN'), findsWidgets);
    expect(find.text('Manage categories'), findsNothing);
    expect(find.text('Recurring transactions'), findsNothing);
  });

  testWidgets('shows sign-in prompt when user is absent', (
    WidgetTester tester,
  ) async {
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
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
          recurringTransactionsRepositoryProvider.overrideWithValue(
            const _StubRecurringTransactionsRepository(),
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
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
          recurringTransactionsRepositoryProvider.overrideWithValue(
            const _StubRecurringTransactionsRepository(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
          routes: <String, WidgetBuilder>{
            GeneralSettingsScreen.routeName: (_) =>
                const GeneralSettingsScreen(),
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(ProfileScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    await tester.tap(find.byTooltip(strings.profileGeneralSettingsTooltip));
    await tester.pumpAndSettle();

    expect(find.byType(GeneralSettingsScreen), findsOneWidget);
  });

  testWidgets('sign out button triggers auth controller sign out', (
    WidgetTester tester,
  ) async {
    bool didSignOut = false;

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
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
          recurringTransactionsRepositoryProvider.overrideWithValue(
            const _StubRecurringTransactionsRepository(),
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

    final Finder signOutButton = find.text(strings.profileSignOutCta);

    await tester.ensureVisible(signOutButton);
    await tester.tap(signOutButton, warnIfMissed: false);
    await tester.pump();

    expect(didSignOut, isTrue);
  });
}
