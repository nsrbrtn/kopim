import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/utils/timezone_utils.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'core/application/app_startup_controller.dart';
import 'core/config/app_config.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/application/theme_mode_controller.dart';
import 'core/theme/domain/app_theme_mode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String timeZoneId = resolveCurrentTimeZoneId();
  tz.setLocalLocation(tz.getLocation(timeZoneId));
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appStartupControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Locale appLocale = ref.watch(appLocaleProvider);
    final ThemeData lightTheme = ref.watch(appThemeProvider);
    final ThemeData darkTheme = ref.watch(appDarkThemeProvider);
    final AppThemeMode appThemeMode = ref.watch(themeModeControllerProvider);
    final ThemeMode themeMode = appThemeMode.toMaterialThemeMode();
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Kopim',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
