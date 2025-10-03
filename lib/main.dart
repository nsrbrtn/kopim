import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_work_scheduler.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/di/injectors.dart';
import 'features/profile/presentation/controllers/auth_controller.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/accounts/presentation/account_details_screen.dart';
import 'features/accounts/presentation/accounts_add_screen.dart';
import 'features/accounts/presentation/edit_account_screen.dart';
import 'features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'features/categories/presentation/screens/manage_categories_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/sign_in_screen.dart';
import 'features/transactions/presentation/add_transaction_screen.dart';
import 'features/recurring_transactions/presentation/screens/recurring_transactions_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  const Settings settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  firestore.settings = settings;

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
    Future<void>.microtask(() async {
      final RecurringWorkScheduler scheduler = ref.read(
        recurringWorkSchedulerProvider,
      );
      await scheduler.initialize();
      await scheduler.scheduleDailyWindowGeneration();
      await scheduler.scheduleMaintenance();
      await scheduler.scheduleDuePostings();
      await ref.read(recurringWindowServiceProvider).rebuildWindow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Locale appLocale = ref.watch(appLocaleProvider);
    ref.watch(syncServiceProvider);
    final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Kopim',
      theme: ThemeData(primarySwatch: Colors.blue),
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
        ManageCategoriesScreen.routeName: (_) => const ManageCategoriesScreen(),
        RecurringTransactionsScreen.routeName: (_) =>
            const RecurringTransactionsScreen(),
      },
      home: authState.when(
        data: (AuthUser? user) =>
            user == null ? const SignInScreen() : const MainNavigationShell(),
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
      ),
    );
  }
}
