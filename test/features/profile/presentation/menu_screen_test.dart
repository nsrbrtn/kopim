import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:kopim/core/theme/application/theme_mode_controller.dart';
import 'package:kopim/core/theme/domain/app_theme_mode.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/profile/presentation/screens/menu_screen.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/presentation/controllers/exact_alarm_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/export_user_data_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/import_user_data_controller.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

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
    exactAlarmControllerProvider.overrideWith(
      () => _FakeExactAlarmController(),
    ),
    exportUserDataControllerProvider.overrideWith(
      () => _FakeExportUserDataController(),
    ),
    importUserDataControllerProvider.overrideWith(
      () => _FakeImportUserDataController(),
    ),
    themeModeControllerProvider.overrideWith(() => _FakeThemeModeController()),
  ];

  testWidgets('displays management actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MenuScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(MenuScreen));
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
          home: const MenuScreen(),
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

    final BuildContext context = tester.element(find.byType(MenuScreen));
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

  testWidgets('opens general settings from floating action button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MenuScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(MenuScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    await tester.tap(find.byTooltip(strings.profileGeneralSettingsTooltip));
    await tester.pumpAndSettle();

    expect(find.byType(GeneralSettingsScreen), findsOneWidget);
  });
}

class _StubDestination extends StatelessWidget {
  const _StubDestination({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

class _FakeHomeDashboardPreferencesController
    extends HomeDashboardPreferencesController {
  @override
  Future<HomeDashboardPreferences> build() async {
    return const HomeDashboardPreferences();
  }
}

class _FakeExactAlarmController extends ExactAlarmController {
  @override
  Future<bool> build() async => true;
}

class _FakeExportUserDataController extends ExportUserDataController {
  @override
  AsyncValue<ExportFileSaveResult?> build() =>
      const AsyncValue<ExportFileSaveResult?>.data(null);
}

class _FakeImportUserDataController extends ImportUserDataController {
  @override
  AsyncValue<ImportUserDataResult?> build() =>
      const AsyncValue<ImportUserDataResult?>.data(null);
}

class _FakeThemeModeController extends ThemeModeController {
  @override
  AppThemeMode build() => const AppThemeMode.system();

  @override
  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
  }
}
