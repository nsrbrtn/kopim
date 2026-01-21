import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart';
import 'package:kopim/features/app_shell/presentation/controllers/main_navigation_controller.dart';
import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_bar.dart';
import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/watch_categories_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/watch_category_tree_use_case.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/screens/menu_screen.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/savings/domain/use_cases/archive_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/get_saving_goals_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/watch_saving_goals_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_recent_transactions_use_case.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/l10n/app_localizations_en.dart';

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

class _StreamAccountRepository implements AccountRepository {
  _StreamAccountRepository(Stream<List<AccountEntity>> stream)
    : _stream = stream.asBroadcastStream();

  final Stream<List<AccountEntity>> _stream;

  @override
  Stream<List<AccountEntity>> watchAccounts() => _stream;

  @override
  Future<AccountEntity?> findById(String id) => throw UnimplementedError();

  @override
  Future<List<AccountEntity>> loadAccounts() => throw UnimplementedError();

  @override
  Future<void> softDelete(String id) => throw UnimplementedError();

  @override
  Future<void> upsert(AccountEntity account) => throw UnimplementedError();
}

class _StreamTransactionRepository implements TransactionRepository {
  _StreamTransactionRepository(Stream<List<TransactionEntity>> stream)
    : _stream = stream.asBroadcastStream();

  final Stream<List<TransactionEntity>> _stream;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _stream;

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    return _stream.map((List<TransactionEntity> items) {
      if (limit == null || limit >= items.length) {
        return items;
      }
      return items.take(limit).toList(growable: false);
    });
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    return const Stream<List<AccountMonthlyTotals>>.empty();
  }

  @override
  Future<TransactionEntity?> findById(String id) => throw UnimplementedError();

  @override
  Future<List<TransactionEntity>> loadTransactions() =>
      throw UnimplementedError();

  @override
  Future<void> softDelete(String id) => throw UnimplementedError();

  @override
  Future<void> upsert(TransactionEntity transaction) =>
      throw UnimplementedError();
}

class _StreamCategoryRepository implements CategoryRepository {
  _StreamCategoryRepository(Stream<List<Category>> stream)
    : _stream = stream.asBroadcastStream();

  final Stream<List<Category>> _stream;

  @override
  Stream<List<Category>> watchCategories() => _stream;

  @override
  Stream<List<CategoryTreeNode>> watchCategoryTree() =>
      Stream<List<CategoryTreeNode>>.value(const <CategoryTreeNode>[]);

  @override
  Future<Category?> findById(String id) => throw UnimplementedError();

  @override
  Future<Category?> findByName(String name) => throw UnimplementedError();

  @override
  Future<List<Category>> loadCategories() => throw UnimplementedError();

  @override
  Future<List<CategoryTreeNode>> loadCategoryTree() =>
      throw UnimplementedError();

  @override
  Future<void> softDelete(String id) => throw UnimplementedError();

  @override
  Future<void> upsert(Category category) => throw UnimplementedError();
}

class _FakeSavingGoalRepository implements SavingGoalRepository {
  const _FakeSavingGoalRepository();

  @override
  Future<SavingGoal> addContribution({
    required SavingGoal goal,
    required int appliedDelta,
    required int newCurrentAmount,
    required DateTime contributedAt,
    String? sourceAccountId,
    String? contributionNote,
  }) async => goal;

  @override
  Future<SavingGoal?> findByName({
    required String userId,
    required String name,
  }) async => null;

  @override
  Future<void> archive(String goalId, DateTime archivedAt) async {}

  @override
  Future<void> create(SavingGoal goal) async {}

  @override
  Future<SavingGoal?> findById(String id) async => null;

  @override
  Future<List<SavingGoal>> loadGoals({required bool includeArchived}) async =>
      const <SavingGoal>[];

  @override
  Future<void> update(SavingGoal goal) async {}

  @override
  Stream<List<SavingGoal>> watchGoals({required bool includeArchived}) =>
      Stream<List<SavingGoal>>.value(const <SavingGoal>[]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DateTime now = DateTime.utc(2024, 1, 1);
  final AccountEntity account = AccountEntity(
    id: 'acc-1',
    name: 'Wallet',
    balanceMinor: BigInt.from(120000),
    currency: 'USD',
    currencyScale: 2,
    type: 'cash',
    createdAt: now,
    updatedAt: now,
  );

  const AuthUser? anonymousUser = null;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ProviderScope buildShell(Widget child) {
    final _StreamAccountRepository accountRepository = _StreamAccountRepository(
      Stream<List<AccountEntity>>.value(<AccountEntity>[account]),
    );
    final _StreamTransactionRepository transactionRepository =
        _StreamTransactionRepository(
          Stream<List<TransactionEntity>>.value(const <TransactionEntity>[]),
        );
    final _StreamCategoryRepository categoryRepository =
        _StreamCategoryRepository(
          Stream<List<Category>>.value(const <Category>[]),
        );
    const _FakeSavingGoalRepository savingGoalRepository =
        _FakeSavingGoalRepository();

    return ProviderScope(
      // ignore: always_specify_types, the Override type is internal to riverpod
      overrides: [
        firebaseInitializationProvider.overrideWith(
          (Ref ref) => Future<void>.value(),
        ),
        authControllerProvider.overrideWith(
          () => _FakeAuthController(anonymousUser),
        ),
        homeDashboardPreferencesControllerProvider.overrideWith(
          () => _FakeHomeDashboardPreferencesController(),
        ),
        accountRepositoryProvider.overrideWithValue(accountRepository),
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        watchAccountsUseCaseProvider.overrideWithValue(
          WatchAccountsUseCase(accountRepository),
        ),
        transactionRepositoryProvider.overrideWithValue(transactionRepository),
        watchRecentTransactionsUseCaseProvider.overrideWithValue(
          WatchRecentTransactionsUseCase(transactionRepository),
        ),
        watchMonthlyAnalyticsUseCaseProvider.overrideWithValue(
          WatchMonthlyAnalyticsUseCase(
            transactionRepository: transactionRepository,
            categoryRepository: categoryRepository,
          ),
        ),
        watchCategoriesUseCaseProvider.overrideWithValue(
          WatchCategoriesUseCase(categoryRepository),
        ),
        watchCategoryTreeUseCaseProvider.overrideWithValue(
          WatchCategoryTreeUseCase(categoryRepository),
        ),
        manageCategoryTreeProvider.overrideWith(
          (Ref ref) =>
              Stream<List<CategoryTreeNode>>.value(const <CategoryTreeNode>[]),
        ),
        homeUpcomingItemsProvider.overrideWith(
          (Ref ref, int limit) =>
              Stream<List<UpcomingItem>>.value(const <UpcomingItem>[]),
        ),
        budgetsStreamProvider.overrideWith(
          (Ref ref) => Stream<List<Budget>>.value(const <Budget>[]),
        ),
        budgetTransactionsStreamProvider.overrideWith(
          (Ref ref) => Stream<List<TransactionEntity>>.value(
            const <TransactionEntity>[],
          ),
        ),
        budgetAccountsStreamProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
        ),
        budgetCategoriesStreamProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
        ),
        computeBudgetProgressUseCaseProvider.overrideWithValue(
          ComputeBudgetProgressUseCase(),
        ),
        savingGoalRepositoryProvider.overrideWithValue(savingGoalRepository),
        watchSavingGoalsUseCaseProvider.overrideWithValue(
          WatchSavingGoalsUseCase(repository: savingGoalRepository),
        ),
        getSavingGoalsUseCaseProvider.overrideWithValue(
          GetSavingGoalsUseCase(repository: savingGoalRepository),
        ),
        archiveSavingGoalUseCaseProvider.overrideWithValue(
          ArchiveSavingGoalUseCase(repository: savingGoalRepository),
        ),
        budgetsWithProgressProvider.overrideWith(
          (Ref ref) =>
              const AsyncValue<List<BudgetProgress>>.data(<BudgetProgress>[]),
        ),
        budgetProgressByIdProvider.overrideWith(
          (Ref ref, String _) => const AsyncValue<BudgetProgress>.loading(),
        ),
        budgetTransactionsByIdProvider.overrideWith(
          (Ref ref, String _) => const AsyncValue<List<TransactionEntity>>.data(
            <TransactionEntity>[],
          ),
        ),
        budgetInstancesByBudgetProvider.overrideWith(
          (Ref ref, String _) async => const <BudgetInstance>[],
        ),
      ],
      child: child,
    );
  }

  Future<void> setWindowSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('displays bottom navigation bar on every primary tab', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(800, 1200));
    await tester.pumpWidget(
      buildShell(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const MenuScreen(),
          },
          home: const MainNavigationShell(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    final Finder bottomNavFinder = find.byType(MainNavigationBar);
    expect(bottomNavFinder, findsOneWidget);

    await tester.tap(find.text('Analytics'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(bottomNavFinder, findsOneWidget);

    await tester.tap(find.text('Budgets'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(bottomNavFinder, findsOneWidget);
  });

  testWidgets('tapping settings tab opens general settings screen', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(800, 1200));
    await tester.pumpWidget(
      buildShell(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const MenuScreen(),
          },
          home: const MainNavigationShell(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Menu'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MenuScreen), findsOneWidget);

    final AppLocalizations strings = AppLocalizationsEn();

    expect(
      find.descendant(
        of: find.byType(MenuScreen),
        matching: find.text(strings.profileMenuTitle),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(MenuScreen),
        matching: find.text(strings.profileManageCategoriesCta),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MenuScreen), findsNothing);
    expect(find.byType(MainNavigationBar), findsOneWidget);
  });

  testWidgets('hides bottom navigation when a secondary route is pushed', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(800, 1200));
    await tester.pumpWidget(
      buildShell(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const MenuScreen(),
          },
          home: const MainNavigationShell(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            const Scaffold(body: Center(child: Text('Child screen'))),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainNavigationBar), findsNothing);

    navigatorKey.currentState!.pop();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainNavigationBar), findsOneWidget);
  });

  testWidgets('keeps bottom navigation bar on wide layouts', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(1200, 1200));
    await tester.pumpWidget(
      buildShell(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const MenuScreen(),
          },
          home: const MainNavigationShell(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainNavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('constrains bottom navigation on extra wide layouts', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(1400, 1200));
    await tester.pumpWidget(
      buildShell(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const MenuScreen(),
          },
          home: const MainNavigationShell(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    final Finder constrainedBarFinder = find.ancestor(
      of: find.byType(MainNavigationBar),
      matching: find.byType(FractionallySizedBox),
    );
    expect(constrainedBarFinder, findsOneWidget);

    final FractionallySizedBox constrainedBar = tester
        .widget<FractionallySizedBox>(constrainedBarFinder);
    expect(constrainedBar.widthFactor, equals(0.5));
  });

  testWidgets('back returns to previous bottom-nav tab', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(800, 1200));
    await tester.pumpWidget(
      buildShell(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const MenuScreen(),
          },
          home: const MainNavigationShell(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(MainNavigationShell)),
    );

    expect(container.read(mainNavigationControllerProvider).currentIndex, 0);
    expect(container.read(mainNavigationControllerProvider).history, isEmpty);

    await tester.tap(find.text('Analytics'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(mainNavigationControllerProvider).currentIndex, 1);
    expect(container.read(mainNavigationControllerProvider).history, <int>[0]);

    await tester.tap(find.text('Assistant'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(mainNavigationControllerProvider).currentIndex, 2);
    expect(container.read(mainNavigationControllerProvider).history, <int>[
      0,
      1,
    ]);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(mainNavigationControllerProvider).currentIndex, 1);
    expect(container.read(mainNavigationControllerProvider).history, <int>[0]);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(mainNavigationControllerProvider).currentIndex, 0);
    expect(container.read(mainNavigationControllerProvider).history, isEmpty);
  });

  testWidgets('wide layout records bottom-nav history', (
    WidgetTester tester,
  ) async {
    await setWindowSize(tester, const Size(1200, 1200));
    await tester.pumpWidget(
      buildShell(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            MenuScreen.routeName: (_) => const MenuScreen(),
          },
          home: const MainNavigationShell(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(MainNavigationShell)),
    );
    expect(container.read(mainNavigationControllerProvider).history, isEmpty);

    await tester.tap(find.text('Analytics'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(mainNavigationControllerProvider).currentIndex, 1);
    expect(container.read(mainNavigationControllerProvider).history, <int>[0]);
  });
}
