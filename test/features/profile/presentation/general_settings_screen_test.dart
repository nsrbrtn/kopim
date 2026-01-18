import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:kopim/core/theme/application/theme_mode_controller.dart';
import 'package:kopim/core/theme/domain/app_theme_mode.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/presentation/controllers/exact_alarm_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/export_user_data_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/import_user_data_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<Override> overrides = <Override>[
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

  testWidgets('shows appearance and exact reminder sections', (
    WidgetTester tester,
  ) async {
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

    expect(find.text(strings.profileThemeHeader), findsOneWidget);
    expect(find.text(strings.settingsNotificationsExactTitle), findsOneWidget);
  });

  testWidgets('renders data transfer actions', (WidgetTester tester) async {
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

    expect(
      find.text(strings.profileGeneralSettingsManagementSection),
      findsOneWidget,
    );

    await tester.tap(
      find.text(strings.profileGeneralSettingsManagementSection),
    );
    await tester.pumpAndSettle();

    expect(find.text(strings.profileExportDataCta), findsWidgets);
    expect(find.text(strings.profileImportDataCta), findsWidgets);
    expect(find.text(strings.profileDataTransferFormatLabel), findsOneWidget);
  });
}

class _FakeExactAlarmController extends ExactAlarmController {
  @override
  Future<bool> build() async {
    return true;
  }
}

class _FakeExportUserDataController extends ExportUserDataController {
  @override
  AsyncValue<ExportFileSaveResult?> build() {
    return const AsyncValue<ExportFileSaveResult?>.data(null);
  }
}

class _FakeImportUserDataController extends ImportUserDataController {
  @override
  AsyncValue<ImportUserDataResult?> build() {
    return const AsyncValue<ImportUserDataResult?>.data(null);
  }
}

class _FakeThemeModeController extends ThemeModeController {
  @override
  AppThemeMode build() {
    return const AppThemeMode.system();
  }

  @override
  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
  }
}
