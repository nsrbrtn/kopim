import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/theme/application/theme_mode_controller.dart';
import 'package:kopim/core/theme/domain/app_theme_mode.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_management_body.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _TestThemeModeController extends ThemeModeController {
  @override
  AppThemeMode build() {
    return const AppThemeMode.system();
  }

  @override
  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
  }
}

void main() {
  testWidgets('toggle updates theme mode state', (WidgetTester tester) async {
    final _TestThemeModeController controller = _TestThemeModeController();

    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [themeModeControllerProvider.overrideWith(() => controller)],
        child:
            // ignore: prefer_const_constructors
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: ProfileThemePreferencesCard()),
            ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(ProfileThemePreferencesCard),
    );
    final AppLocalizations strings = AppLocalizations.of(context)!;

    expect(find.text(strings.profileDarkModeSystemActive), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(controller.debugState, const AppThemeMode.dark());

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(controller.debugState, const AppThemeMode.light());

    await tester.tap(find.text(strings.profileThemeHeader));
    await tester.pumpAndSettle();

    await tester.tap(find.text(strings.profileDarkModeSystemCta));
    await tester.pump();

    expect(controller.debugState, const AppThemeMode.system());
  });
}

extension on ThemeModeController {
  AppThemeMode get debugState => state;
}
