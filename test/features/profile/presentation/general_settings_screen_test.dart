import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

class _RecordingNavigatorObserver extends NavigatorObserver {
  _RecordingNavigatorObserver(this.pushedRoutes);

  final List<Route<dynamic>> pushedRoutes;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<Override> overrides = <Override>[
    homeDashboardPreferencesControllerProvider.overrideWith(
      () => _FakeHomeDashboardPreferencesController(),
    ),
    budgetsWithProgressProvider.overrideWith(
      (Ref ref) =>
          const AsyncValue<List<BudgetProgress>>.data(<BudgetProgress>[]),
    ),
  ];

  testWidgets('displays management actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GeneralSettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(GeneralSettingsScreen),
    );
    final AppLocalizations strings = AppLocalizations.of(context)!;

    expect(find.text(strings.profileManageCategoriesCta), findsOneWidget);
    expect(find.text(strings.profileUpcomingPaymentsCta), findsOneWidget);
  });

  testWidgets('navigates to management screens', (WidgetTester tester) async {
    final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];
    final NavigatorObserver observer = _RecordingNavigatorObserver(
      pushedRoutes,
    );
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GeneralSettingsScreen(),
          routes: <String, WidgetBuilder>{
            ManageCategoriesScreen.routeName: (_) =>
                const _StubDestination(label: 'manage-categories-destination'),
            UpcomingPaymentsScreen.routeName: (_) =>
                const _StubDestination(label: 'upcoming-destination'),
          },
          navigatorObservers: <NavigatorObserver>[observer],
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(GeneralSettingsScreen),
    );
    final AppLocalizations strings = AppLocalizations.of(context)!;

    await tester.tap(find.text(strings.profileManageCategoriesCta));
    await tester.pumpAndSettle();

    expect(
      pushedRoutes.map((Route<dynamic> route) => route.settings.name),
      contains(ManageCategoriesScreen.routeName),
    );
    expect(find.text('manage-categories-destination'), findsOneWidget);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text(strings.profileUpcomingPaymentsCta));
    await tester.pumpAndSettle();

    expect(
      pushedRoutes.map((Route<dynamic> route) => route.settings.name),
      contains(UpcomingPaymentsScreen.routeName),
    );
    expect(find.text('upcoming-destination'), findsOneWidget);
  });
}

class _FakeHomeDashboardPreferencesController
    extends HomeDashboardPreferencesController {
  _FakeHomeDashboardPreferencesController();

  @override
  Future<HomeDashboardPreferences> build() async {
    return const HomeDashboardPreferences();
  }
}

class _StubDestination extends StatelessWidget {
  const _StubDestination({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}
