import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Для ProviderScope
import 'package:kopim/l10n/app_localizations.dart'; // Генерируется из l10n
import 'firebase_options.dart'; // Генерированный из flutterfire configure
import 'core/config/app_config.dart'; // Создайте этот файл для providers (locale, theme, auth)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Включение offline persistence с учётом платформ
  if (kIsWeb) {
    // Для Web
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } else {
    // Для mobile/desktop
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Инициализация локализации (Intl) через app_config providers
  // Это будет в ProviderScope, но базовая init здесь (если нужно кастомное)
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget { // Используем ConsumerWidget для Riverpod доступа
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Чтение locale из provider (в app_config.dart определите appLocaleProvider)
    final Locale appLocale = ref.watch(appLocaleProvider); // Пример: из core/config/app_config.dart

    return MaterialApp(
      title: 'Kopim',
      theme: ThemeData(primarySwatch: Colors.blue),
      locale: appLocale, // Из provider для динамической локализации
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kopim App')),
      body: const Center(child: Text('Welcome to Kopim!')),
    );
  }
}