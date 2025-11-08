import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
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
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_job.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
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
  testWidgets('иконка настроек открывает экран общих настроек', (
    WidgetTester tester,
  ) async {
    const AuthUser signedInUser = AuthUser(
      uid: 'user-1',
      email: 'test@example.com',
      isAnonymous: false,
    );
    final Profile profile = Profile(
      uid: signedInUser.uid,
      name: 'Tester',
      updatedAt: DateTime(2024, 1, 1),
    );
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
          ).overrideWith(() => _FakeProfileController(profile)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          profileEventRecorderProvider.overrideWithValue(eventRecorder),
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
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const Scaffold(),
          },
          home: const ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.byType(MenuScreen), findsOneWidget);
  });
}
