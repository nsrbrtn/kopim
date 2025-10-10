import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/utils/timezone_utils.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'core/config/app_config.dart';
import 'core/di/injectors.dart';
import 'core/application/app_startup_controller.dart';
import 'core/theme/application/theme_mode_controller.dart';
import 'core/theme/domain/app_theme_mode.dart';
import 'features/profile/presentation/controllers/auth_controller.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/accounts/presentation/account_details_screen.dart';
import 'features/accounts/presentation/accounts_add_screen.dart';
import 'features/accounts/presentation/edit_account_screen.dart';
import 'features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'features/categories/presentation/screens/manage_categories_screen.dart';
import 'features/profile/presentation/screens/general_settings_screen.dart';
import 'features/profile/presentation/screens/profile_management_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/sign_in_screen.dart';
import 'features/transactions/presentation/add_transaction_screen.dart';
import 'features/transactions/presentation/screens/all_transactions_screen.dart';
import 'features/recurring_transactions/presentation/screens/add_recurring_rule_screen.dart';
import 'features/recurring_transactions/presentation/screens/recurring_transactions_screen.dart';

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
    final AsyncValue<void> startupState = ref.watch(
      appStartupControllerProvider,
    );
    final ThemeData lightTheme = ref.watch(appThemeProvider);
    final ThemeData darkTheme = ref.watch(appDarkThemeProvider);
    final AppThemeMode appThemeMode = ref.watch(themeModeControllerProvider);
    final ThemeMode themeMode = appThemeMode.toMaterialThemeMode();

    return MaterialApp(
      title: 'Kopim',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: <String, WidgetBuilder>{
        MainNavigationShell.routeName: (_) => const MainNavigationShell(),
        AnalyticsScreen.routeName: (_) => const AnalyticsScreen(),
        AddAccountScreen.routeName: (_) => const AddAccountScreen(),
        AccountDetailsScreen.routeName: (BuildContext context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args is! AccountDetailsScreenArgs) {
            throw ArgumentError('AccountDetailsScreenArgs expected');
          }
          return AccountDetailsScreen(accountId: args.accountId);
        },
        EditAccountScreen.routeName: (BuildContext context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args is! EditAccountScreenArgs) {
            throw ArgumentError('EditAccountScreenArgs expected');
          }
          return EditAccountScreen(account: args.account);
        },
        AddTransactionScreen.routeName: (_) => const AddTransactionScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        GeneralSettingsScreen.routeName: (_) => const GeneralSettingsScreen(),
        ProfileManagementScreen.routeName: (_) =>
            const ProfileManagementScreen(),
        ManageCategoriesScreen.routeName: (_) => const ManageCategoriesScreen(),
        RecurringTransactionsScreen.routeName: (_) =>
            const RecurringTransactionsScreen(),
        AddRecurringRuleScreen.routeName: (_) => const AddRecurringRuleScreen(),
        AllTransactionsScreen.routeName: (_) => const AllTransactionsScreen(),
      },
      home: startupState.when(
        data: (_) => _AppHome(authState: ref.watch(authControllerProvider)),
        loading: () => const _StartupPlaceholder(),
        error: (Object error, StackTrace stackTrace) =>
            _StartupErrorView(error: error),
      ),
    );
  }
}

class _AppHome extends ConsumerWidget {
  const _AppHome({required this.authState});

  final AsyncValue<AuthUser?> authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return authState.when(
      data: (AuthUser? user) {
        if (user != null && !user.isGuest) {
          ref.watch(syncServiceProvider);
        }
        return user == null
            ? const SignInScreen()
            : const MainNavigationShell();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (Object error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Authentication error: $error'),
          ),
        ),
      ),
    );
  }
}

class _StartupPlaceholder extends StatelessWidget {
  const _StartupPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Startup error: $error'),
        ),
      ),
    );
  }
}
