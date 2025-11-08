import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows dashboard visibility toggles', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          homeDashboardPreferencesControllerProvider.overrideWith(
            () => _FakeHomeDashboardPreferencesController(),
          ),
        ],
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

    expect(find.text(strings.settingsHomeSectionTitle), findsOneWidget);

    await tester.tap(find.text(strings.settingsHomeSectionTitle));
    await tester.pumpAndSettle();

    expect(find.text(strings.settingsHomeBudgetTitle), findsOneWidget);
    expect(find.text(strings.settingsHomeSavingsTitle), findsOneWidget);
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
