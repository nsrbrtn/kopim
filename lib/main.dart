import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/di/injectors.dart';
import 'features/profile/presentation/controllers/auth_controller.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/accounts/presentation/accounts_add_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/sign_in_screen.dart';
import 'features/transactions/presentation/add_transaction_screen.dart';

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        HomeScreen.routeName: (_) => const HomeScreen(),
        AnalyticsScreen.routeName: (_) => const AnalyticsScreen(),
        AddAccountScreen.routeName: (_) => const AddAccountScreen(),
        AddTransactionScreen.routeName: (_) => const AddTransactionScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
      },
      home: authState.when(
        data: (AuthUser? user) =>
            user == null ? const SignInScreen() : const HomeScreen(),
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
