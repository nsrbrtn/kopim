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
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/sign_in_screen.dart';

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
      home: authState.when(
        data: (AuthUser? user) =>
            user == null
                ? const SignInScreen()
                : const ProfileScreen(),
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


