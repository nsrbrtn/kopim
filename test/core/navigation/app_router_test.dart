import 'dart:async';

import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/core/navigation/app_router.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_config.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/app_shell/presentation/providers/main_navigation_tabs_provider.dart';
import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_choice_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_preflight_screen.dart';
import 'package:kopim/features/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:kopim/features/transactions/presentation/controllers/all_transactions_providers.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/core/application/app_startup_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/use_cases/save_budget_use_case.dart';
import 'package:kopim/features/budgets/domain/use_cases/delete_budget_use_case.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/budgets/presentation/budget_overview_screen.dart';
import 'package:kopim/features/budgets/presentation/budget_form_screen.dart';
import 'package:kopim/features/budgets/presentation/budgets_screen.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/profile/presentation/controllers/active_currency_code_provider.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/presentation/providers/upcoming_payment_selection_providers.dart';

class _FakeConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      const <ConnectivityResult>[ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();
}

class _FakeTimeService implements TimeService {
  @override
  DateTime nowLocal() => DateTime(2024, 1, 15);

  @override
  int nowMs() => DateTime(2024, 1, 15).millisecondsSinceEpoch;

  @override
  DateTime toLocal(int epochMs) =>
      DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: false);

  @override
  int toEpochMs(DateTime dt) => dt.millisecondsSinceEpoch;

  @override
  DateTime atLocalDateTime(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) => DateTime(year, month, day, hour, minute);

  @override
  int parseHhmmToMinutes(String hhmm) {
    final List<String> parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

class _FakeBudgetRepository implements BudgetRepository {
  @override
  Future<Budget?> findById(String id) async => null;

  @override
  Future<void> softDelete(String id) async {}

  @override
  Future<void> deleteInstance(String id) async {}

  @override
  Future<List<BudgetInstance>> loadInstances(String budgetId) async =>
      const <BudgetInstance>[];

  @override
  Future<List<Budget>> loadBudgets() async => const <Budget>[];

  @override
  Future<void> upsert(Budget budget) async {}

  @override
  Future<void> upsertInstance(BudgetInstance instance) async {}

  @override
  Stream<List<BudgetInstance>> watchInstances(String budgetId) =>
      const Stream<List<BudgetInstance>>.empty();

  @override
  Stream<List<Budget>> watchBudgets() => const Stream<List<Budget>>.empty();
}

class _FakeDataModeController extends DataModeController {
  _FakeDataModeController(this._nextState);

  final DataModeState _nextState;

  @override
  FutureOr<DataModeState> build() async => _nextState;

  @override
  Future<DataModeState> refreshForCurrentContext() async {
    state = AsyncData<DataModeState>(_nextState);
    return _nextState;
  }
}

class _FakeAppStartupController extends AppStartupController {
  @override
  AppStartupResult build() => const AsyncValue<void>.data(null);

  @override
  Future<void> initialize() async {}
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this.user);

  final AuthUser? user;

  @override
  Future<AuthUser?> build() async => user;
}

class _DelayedAuthController extends AuthController {
  _DelayedAuthController(this._future);

  final Future<AuthUser?> _future;

  @override
  Future<AuthUser?> build() => _future;
}

class _MutableAuthController extends AuthController {
  _MutableAuthController(this._initialUser);

  final AuthUser? _initialUser;

  @override
  Future<AuthUser?> build() async => _initialUser;

  void setUser(AuthUser? user) {
    state = AsyncValue<AuthUser?>.data(user);
  }
}

class _FakeAnalyticsFilterController extends AnalyticsFilterController {
  _FakeAnalyticsFilterController(this._state);

  final AnalyticsFilterState _state;

  @override
  AnalyticsFilterState build() => _state;
}

class _FakeProfileController extends ProfileController {
  _FakeProfileController(this._profile);

  final Profile? _profile;

  @override
  Future<Profile?> build(String uid) async => _profile;
}

class _FakeCloudEntitlementRepository implements CloudEntitlementRepository {
  _FakeCloudEntitlementRepository(this.state);
  final CloudEntitlementState state;

  @override
  Future<CloudEntitlementResult> activateKey(String key) async {
    return CloudEntitlementResult(success: true, state: state);
  }

  @override
  Future<void> clearEntitlement() async {}

  @override
  Future<CloudEntitlementState> getCachedState() async {
    return state;
  }

  @override
  Future<CloudEntitlementState> refreshFromCurrentToken() async {
    return state;
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.user});
  final AuthUser? user;

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => user;

  @override
  Future<void> deleteCurrentUser() async {}

  @override
  Future<AuthUser> reauthenticate(SignInRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signIn(SignInRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> signUp(SignUpRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInOffline() async {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthUser> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> forceRefreshIdToken() async {}
}

Widget _emptyTabBody(BuildContext context, WidgetRef ref) =>
    const SizedBox.shrink();

class _TestApp extends ConsumerWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

void main() {
  const AuthUser testUser = AuthUser(uid: 'user-123', isAnonymous: true);
  final Profile testProfile = Profile(
    uid: testUser.uid,
    name: 'Test User',
    currency: ProfileCurrency.rub,
    locale: 'ru',
    photoUrl: null,
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  Future<void> setWindowSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    required dynamic authOverride,
    List<Override> extraOverrides = const <Override>[],
  }) async {
    final AnalyticsFilterState analyticsFilterState = AnalyticsFilterState(
      dateRange: DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      ),
    );
    final AnalyticsOverview analyticsOverview = AnalyticsOverview(
      totalIncome: MoneyAmount(minor: BigInt.zero, scale: 2),
      totalExpense: MoneyAmount(minor: BigInt.zero, scale: 2),
      netBalance: MoneyAmount(minor: BigInt.zero, scale: 2),
      topExpenseCategories: <AnalyticsCategoryBreakdown>[],
      topIncomeCategories: <AnalyticsCategoryBreakdown>[],
    );
    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          mainNavigationTabsProvider.overrideWithValue(<NavigationTabConfig>[
            NavigationTabConfig(
              id: 'test-home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              labelBuilder: (BuildContext context) => 'Home',
              contentBuilder: (BuildContext context, WidgetRef ref) =>
                  const NavigationTabContent(bodyBuilder: _emptyTabBody),
            ),
            NavigationTabConfig(
              id: 'test-analytics',
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              labelBuilder: (BuildContext context) => 'Analytics',
              contentBuilder: (BuildContext context, WidgetRef ref) =>
                  const NavigationTabContent(bodyBuilder: _emptyTabBody),
            ),
          ]),
          appStartupControllerProvider.overrideWith(
            _FakeAppStartupController.new,
          ),
          cloudEntitlementRepositoryProvider.overrideWithValue(
            _FakeCloudEntitlementRepository(CloudEntitlementState.active),
          ),
          cloudAuthRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(user: testUser),
          ),
          authOverride,
          profileControllerProvider(
            testUser.uid,
          ).overrideWith(() => _FakeProfileController(testProfile)),
          analyticsFilterControllerProvider.overrideWith(
            () => _FakeAnalyticsFilterController(analyticsFilterState),
          ),
          analyticsFilteredStatsProvider(topCategoriesLimit: 5).overrideWith(
            (Ref ref) => Stream<AnalyticsOverview>.value(analyticsOverview),
          ),
          analyticsCreditDebtOperationsProvider.overrideWith(
            (Ref ref) => Stream<CreditDebtOperationsOverview>.value(
              CreditDebtOperationsOverview.empty(),
            ),
          ),
          analyticsCategoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
          analyticsAccountsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
          ),
          analyticsTransferTransactionsProvider.overrideWith(
            (Ref ref) => Stream<List<TransactionEntity>>.value(
              const <TransactionEntity>[],
            ),
          ),
          filteredTransactionsProvider.overrideWithValue(
            const AsyncValue<List<TransactionEntity>>.data(
              <TransactionEntity>[],
            ),
          ),
          allTransactionsAccountsProvider.overrideWithValue(
            const AsyncValue<List<AccountEntity>>.data(<AccountEntity>[]),
          ),
          allTransactionsCategoriesProvider.overrideWithValue(
            const AsyncValue<List<Category>>.data(<Category>[]),
          ),
          allTransactionsCreditsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<CreditEntity>>.value(const <CreditEntity>[]),
          ),
          ...extraOverrides,
        ],
        child: const _TestApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('renders MainNavigationShell on /home', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _FakeAuthController(testUser),
      ),
      extraOverrides: <Override>[
        cloudActivationPreflightProvider.overrideWithValue(
          const CloudActivationPreflightState(
            CloudActivationPreflightStatus.unknown,
          ),
        ),
      ],
    );
    expect(find.byType(MainNavigationShell), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('navigates to analytics route', (WidgetTester tester) async {
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _FakeAuthController(testUser),
      ),
    );
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);
    router.go(AnalyticsScreen.routeName);
    await tester.pumpAndSettle();
    expect(find.byType(AnalyticsScreen), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('navigates to all transactions route', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _FakeAuthController(testUser),
      ),
    );
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);
    router.go(AllTransactionsScreen.routeName);
    await tester.pumpAndSettle();
    expect(find.byType(AllTransactionsScreen), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('restores deep link after auth loading', (
    WidgetTester tester,
  ) async {
    final Completer<AuthUser?> completer = Completer<AuthUser?>();
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _DelayedAuthController(completer.future),
      ),
    );

    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);

    router.go(AnalyticsScreen.routeName);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(AnalyticsScreen), findsNothing);

    completer.complete(testUser);
    await tester.pumpAndSettle();
    expect(find.byType(AnalyticsScreen), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('restores deep link after login when user was null', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _MutableAuthController(null),
      ),
    );

    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);

    router.go(AnalyticsScreen.routeName);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AnalyticsScreen), findsNothing);

    final AuthController authController = container.read(
      authControllerProvider.notifier,
    );
    (authController as _MutableAuthController).setUser(testUser);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AnalyticsScreen), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('redirects from / to /home', (WidgetTester tester) async {
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _FakeAuthController(testUser),
      ),
    );
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);

    router.go('/');
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationShell), findsOneWidget);
    expect(router.state.uri.toString(), MainNavigationShell.routeName);
    await disposeApp(tester);
  });

  testWidgets('navigates to cloud activation preflight route', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _FakeAuthController(testUser),
      ),
    );
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);

    router.go(CloudActivationPreflightScreen.routeName);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CloudActivationPreflightScreen), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('navigates to cloud activation choice route', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _FakeAuthController(testUser),
      ),
    );
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);

    router.go(CloudActivationChoiceScreen.routeName);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CloudActivationChoiceScreen), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('navigates to budget overview screen with budgetId query param', (
    WidgetTester tester,
  ) async {
    final Budget budget = Budget(
      id: 'budget-1',
      title: 'Food & Trans',
      period: BudgetPeriod.monthly,
      startDate: DateTime(2024, 1, 1),
      amountMinor: BigInt.from(80000),
      amountScale: 2,
      scope: BudgetScope.byCategory,
      categories: const <String>['cat-1'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    final BudgetInstance instance = BudgetInstance(
      id: 'instance-1',
      budgetId: 'budget-1',
      periodStart: DateTime(2024, 1, 1),
      periodEnd: DateTime(2024, 1, 31),
      amountMinor: BigInt.from(80000),
      spentMinor: BigInt.from(0),
      amountScale: 2,
      status: BudgetInstanceStatus.active,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    final BudgetProgress progress = BudgetProgress(
      budget: budget,
      instance: instance,
      spent: MoneyAmount(minor: BigInt.from(0), scale: 2),
      remaining: MoneyAmount(minor: BigInt.from(80000), scale: 2),
      utilization: 0.0,
      isExceeded: false,
    );

    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _FakeAuthController(testUser),
      ),
      extraOverrides: <Override>[
        budgetProgressByIdProvider(
          'budget-1',
        ).overrideWithValue(AsyncValue<BudgetProgress?>.data(progress)),
        budgetTransactionsStreamProvider.overrideWith(
          (Ref ref) => Stream<List<TransactionEntity>>.value(
            const <TransactionEntity>[],
          ),
        ),
        budgetCategoriesStreamProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
        ),
        budgetAccountsStreamProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
        ),
        homeUpcomingItemsProvider(limit: 12).overrideWithValue(
          const AsyncValue<List<UpcomingItem>>.data(<UpcomingItem>[]),
        ),
        watchUpcomingPaymentsProvider.overrideWith(
          (Ref ref) =>
              Stream<List<UpcomingPayment>>.value(const <UpcomingPayment>[]),
        ),
        upcomingPaymentAccountsProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
        ),
        upcomingPaymentCategoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
        ),
        timeServiceProvider.overrideWithValue(_FakeTimeService()),
        activeCurrencyCodeProvider.overrideWithValue('USD'),
      ],
    );

    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);

    router.go(const BudgetOverviewScreenArgs(budgetId: 'budget-1').location);
    await tester.pumpAndSettle();

    expect(find.byType(BudgetOverviewScreen), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets(
    'renders not found error in budget overview when budgetId does not exist',
    (WidgetTester tester) async {
      await pumpApp(
        tester,
        authOverride: authControllerProvider.overrideWith(
          () => _FakeAuthController(testUser),
        ),
        extraOverrides: <Override>[
          budgetProgressByIdProvider(
            'non-existent',
          ).overrideWithValue(const AsyncValue<BudgetProgress?>.data(null)),
          budgetTransactionsStreamProvider.overrideWith(
            (Ref ref) => Stream<List<TransactionEntity>>.value(
              const <TransactionEntity>[],
            ),
          ),
          budgetCategoriesStreamProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
          budgetAccountsStreamProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
          ),
          homeUpcomingItemsProvider(limit: 12).overrideWithValue(
            const AsyncValue<List<UpcomingItem>>.data(<UpcomingItem>[]),
          ),
          watchUpcomingPaymentsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<UpcomingPayment>>.value(const <UpcomingPayment>[]),
          ),
          upcomingPaymentAccountsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
          ),
          upcomingPaymentCategoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
          timeServiceProvider.overrideWithValue(_FakeTimeService()),
          activeCurrencyCodeProvider.overrideWithValue('USD'),
        ],
      );

      final BuildContext context = tester.element(find.byType(MaterialApp));
      final ProviderContainer container = ProviderScope.containerOf(context);
      final GoRouter router = container.read(appRouterProvider);

      router.go(
        const BudgetOverviewScreenArgs(budgetId: 'non-existent').location,
      );
      await tester.pumpAndSettle();

      expect(find.byType(BudgetOverviewScreen), findsOneWidget);
      final BuildContext screenContext = tester.element(
        find.byType(BudgetOverviewScreen),
      );
      final AppLocalizations strings = AppLocalizations.of(screenContext)!;
      expect(
        find.textContaining(
          strings.localeName == 'ru' ? 'Бюджет не найден' : 'Budget not found',
        ),
        findsOneWidget,
      );
      await disposeApp(tester);
    },
  );

  testWidgets(
    'navigates to budget form screen in creation mode (no budgetId, no extra)',
    (WidgetTester tester) async {
      await pumpApp(
        tester,
        authOverride: authControllerProvider.overrideWith(
          () => _FakeAuthController(testUser),
        ),
        extraOverrides: <Override>[
          saveBudgetUseCaseProvider.overrideWithValue(
            SaveBudgetUseCase(repository: _FakeBudgetRepository()),
          ),
          deleteBudgetUseCaseProvider.overrideWithValue(
            DeleteBudgetUseCase(repository: _FakeBudgetRepository()),
          ),
          budgetCategoriesStreamProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
          budgetAccountsStreamProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
          ),
        ],
      );

      final BuildContext context = tester.element(find.byType(MaterialApp));
      final ProviderContainer container = ProviderScope.containerOf(context);
      final GoRouter router = container.read(appRouterProvider);

      router.go(BudgetFormScreen.routeName);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetFormScreen), findsOneWidget);
      await disposeApp(tester);
    },
  );

  testWidgets(
    'navigates to budget form screen in edit mode (via query parameter with fallback)',
    (WidgetTester tester) async {
      final Budget budget = Budget(
        id: 'budget-1',
        title: 'Food & Trans',
        period: BudgetPeriod.monthly,
        startDate: DateTime(2024, 1, 1),
        amountMinor: BigInt.from(80000),
        amountScale: 2,
        scope: BudgetScope.byCategory,
        categories: const <String>['cat-1'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await pumpApp(
        tester,
        authOverride: authControllerProvider.overrideWith(
          () => _FakeAuthController(testUser),
        ),
        extraOverrides: <Override>[
          saveBudgetUseCaseProvider.overrideWithValue(
            SaveBudgetUseCase(repository: _FakeBudgetRepository()),
          ),
          deleteBudgetUseCaseProvider.overrideWithValue(
            DeleteBudgetUseCase(repository: _FakeBudgetRepository()),
          ),
          budgetsStreamProvider.overrideWith(
            (Ref ref) => Stream<List<Budget>>.value(<Budget>[budget]),
          ),
          budgetCategoriesStreamProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
          budgetAccountsStreamProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
          ),
        ],
      );

      final BuildContext context = tester.element(find.byType(MaterialApp));
      final ProviderContainer container = ProviderScope.containerOf(context);
      final GoRouter router = container.read(appRouterProvider);

      final String location = Uri(
        path: BudgetFormScreen.routeName,
        queryParameters: <String, String>{'budgetId': 'budget-1'},
      ).toString();

      router.go(location);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetFormScreen), findsOneWidget);
      expect(find.text('Food & Trans'), findsWidgets);
      await disposeApp(tester);
    },
  );

  testWidgets('navigates to sign in screen with signUp query param', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(800, 1200));
    final _FakeConnectivity connectivity = _FakeConnectivity();
    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _MutableAuthController(null),
      ),
      extraOverrides: <Override>[
        connectivityProvider.overrideWithValue(connectivity),
        dataModeControllerProvider.overrideWith(
          () => _FakeDataModeController(
            const DataModeState(
              dataMode: DataMode.cloudEnabled,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          ),
        ),
      ],
    );

    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);

    final String location = Uri(
      path: SignInScreen.routeName,
      queryParameters: <String, String>{'signUp': 'true'},
    ).toString();

    router.go(location);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.text('Создать'), findsOneWidget);
    expect(find.text('Войти в аккаунт'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('BudgetOverviewScreen deleted fallback routing', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(800, 1200));
    final Budget budget = Budget(
      id: 'budget-1',
      title: 'Food & Trans',
      period: BudgetPeriod.monthly,
      startDate: DateTime(2024, 1, 1),
      amountMinor: BigInt.from(80000),
      amountScale: 2,
      scope: BudgetScope.byCategory,
      categories: const <String>['cat-1'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    final BudgetInstance instance = BudgetInstance(
      id: 'instance-1',
      budgetId: 'budget-1',
      periodStart: DateTime(2024, 1, 1),
      periodEnd: DateTime(2024, 1, 31),
      amountMinor: BigInt.from(80000),
      spentMinor: BigInt.from(0),
      amountScale: 2,
      status: BudgetInstanceStatus.active,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    final BudgetProgress progress = BudgetProgress(
      budget: budget,
      instance: instance,
      spent: MoneyAmount(minor: BigInt.from(0), scale: 2),
      remaining: MoneyAmount(minor: BigInt.from(80000), scale: 2),
      utilization: 0.0,
      isExceeded: false,
    );

    await pumpApp(
      tester,
      authOverride: authControllerProvider.overrideWith(
        () => _FakeAuthController(testUser),
      ),
      extraOverrides: <Override>[
        budgetProgressByIdProvider(
          'budget-1',
        ).overrideWithValue(AsyncValue<BudgetProgress?>.data(progress)),
        budgetsWithProgressProvider.overrideWithValue(
          AsyncValue<List<BudgetProgress>>.data(<BudgetProgress>[progress]),
        ),
        budgetTransactionsStreamProvider.overrideWith(
          (Ref ref) => Stream<List<TransactionEntity>>.value(
            const <TransactionEntity>[],
          ),
        ),
        budgetsStreamProvider.overrideWith(
          (Ref ref) => Stream<List<Budget>>.value(<Budget>[budget]),
        ),
        budgetCategoriesStreamProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
        ),
        budgetAccountsStreamProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
        ),
        homeUpcomingItemsProvider(limit: 12).overrideWithValue(
          const AsyncValue<List<UpcomingItem>>.data(<UpcomingItem>[]),
        ),
        watchUpcomingPaymentsProvider.overrideWith(
          (Ref ref) =>
              Stream<List<UpcomingPayment>>.value(const <UpcomingPayment>[]),
        ),
        upcomingPaymentAccountsProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
        ),
        upcomingPaymentCategoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
        ),
        timeServiceProvider.overrideWithValue(_FakeTimeService()),
        activeCurrencyCodeProvider.overrideWithValue('USD'),
        saveBudgetUseCaseProvider.overrideWithValue(
          SaveBudgetUseCase(repository: _FakeBudgetRepository()),
        ),
        deleteBudgetUseCaseProvider.overrideWithValue(
          DeleteBudgetUseCase(repository: _FakeBudgetRepository()),
        ),
        computeBudgetProgressUseCaseProvider.overrideWithValue(
          ComputeBudgetProgressUseCase(),
        ),
      ],
    );

    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);

    router.go(const BudgetOverviewScreenArgs(budgetId: 'budget-1').location);
    await tester.pumpAndSettle();

    expect(find.byType(BudgetOverviewScreen), findsOneWidget);

    final BuildContext screenContext = tester.element(
      find.byType(BudgetOverviewScreen),
    );
    final AppLocalizations strings = AppLocalizations.of(screenContext)!;
    final Finder editBtn = find.text(strings.editButtonLabel);
    expect(editBtn, findsOneWidget);
    await tester.tap(editBtn);
    await tester.pumpAndSettle();

    expect(find.byType(BudgetFormScreen), findsOneWidget);

    final Finder deleteBtn = find.text(strings.deleteButtonLabel);
    expect(deleteBtn, findsOneWidget);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    final Finder confirmBtn = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text(strings.deleteButtonLabel),
    );
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(find.byType(BudgetsScreen), findsOneWidget);
    await disposeApp(tester);
  });
}
