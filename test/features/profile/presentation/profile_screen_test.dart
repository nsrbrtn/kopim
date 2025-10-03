import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_job.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/recurring_transactions_screen.dart';
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
    expect(find.text('Manage categories'), findsOneWidget);
    expect(find.text('Recurring transactions'), findsOneWidget);
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

  testWidgets('tapping manage categories button opens categories screen', (
    WidgetTester tester,
  ) async {
    final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];
    final NavigatorObserver observer = _RecordingNavigatorObserver(
      pushedRoutes,
    );

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
            ManageCategoriesScreen.routeName: (_) =>
                const ManageCategoriesScreen(),
            RecurringTransactionsScreen.routeName: (_) =>
                const RecurringTransactionsScreen(),
          },
          navigatorObservers: <NavigatorObserver>[observer],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manage categories'));
    await tester.pumpAndSettle();

    expect(
      pushedRoutes.map((Route<dynamic> route) => route.settings.name),
      contains(ManageCategoriesScreen.routeName),
    );
    expect(find.byType(ManageCategoriesScreen), findsOneWidget);
  });

  testWidgets(
    'tapping recurring transactions button opens recurring transactions screen',
    (WidgetTester tester) async {
      final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];
      final NavigatorObserver observer = _RecordingNavigatorObserver(
        pushedRoutes,
      );

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
              ManageCategoriesScreen.routeName: (_) =>
                  const ManageCategoriesScreen(),
              RecurringTransactionsScreen.routeName: (_) =>
                  const RecurringTransactionsScreen(),
            },
            navigatorObservers: <NavigatorObserver>[observer],
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Recurring transactions'));
      await tester.tap(find.text('Recurring transactions'));
      await tester.pumpAndSettle();

      expect(
        pushedRoutes.map((Route<dynamic> route) => route.settings.name),
        contains(RecurringTransactionsScreen.routeName),
      );
      expect(find.byType(RecurringTransactionsScreen), findsOneWidget);
    },
  );

  testWidgets('sign out button triggers auth controller sign out', (
    WidgetTester tester,
  ) async {
    bool didSignOut = false;

    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(
            () => _SignOutSpyAuthController(
              signedInUser,
              () => didSignOut = true,
            ),
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

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out'));
    await tester.pump();

    expect(didSignOut, isTrue);
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  _RecordingNavigatorObserver(this.pushedRoutes);

  final List<Route<dynamic>> pushedRoutes;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}
