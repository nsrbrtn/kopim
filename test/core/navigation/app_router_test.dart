import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:kopim/features/transactions/presentation/controllers/all_transactions_providers.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/main.dart';
import 'package:kopim/core/application/app_startup_controller.dart';

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

class _FakeAnalyticsFilterController extends AnalyticsFilterController {
  _FakeAnalyticsFilterController(this._state);

  final AnalyticsFilterState _state;

  @override
  AnalyticsFilterState build() => _state;
}

Widget _emptyTabBody(BuildContext context, WidgetRef ref) =>
    const SizedBox.shrink();

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    final AnalyticsFilterState analyticsFilterState = AnalyticsFilterState(
      dateRange: DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      ),
    );
    const AnalyticsOverview analyticsOverview = AnalyticsOverview(
      totalIncome: 0,
      totalExpense: 0,
      netBalance: 0,
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
          authControllerProvider.overrideWith(
            () => _FakeAuthController(AuthUser.guest()),
          ),
          analyticsFilterControllerProvider.overrideWith(
            () => _FakeAnalyticsFilterController(analyticsFilterState),
          ),
          analyticsFilteredStatsProvider(topCategoriesLimit: 5).overrideWith(
            (Ref ref) => Stream<AnalyticsOverview>.value(analyticsOverview),
          ),
          analyticsCategoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
          analyticsAccountsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
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
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('renders MainNavigationShell on /home', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(MainNavigationShell), findsOneWidget);
  });

  testWidgets('navigates to analytics route', (WidgetTester tester) async {
    await pumpApp(tester);
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);
    router.go(AnalyticsScreen.routeName);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AnalyticsScreen), findsOneWidget);
  });

  testWidgets('navigates to all transactions route', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final ProviderContainer container = ProviderScope.containerOf(context);
    final GoRouter router = container.read(appRouterProvider);
    router.go(AllTransactionsScreen.routeName);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AllTransactionsScreen), findsOneWidget);
  });
}
