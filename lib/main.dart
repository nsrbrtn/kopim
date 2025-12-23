import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/l10n/app_localizations.dart';
import 'core/application/app_startup_controller.dart';
import 'core/application/sync_coordinator.dart';
import 'core/config/app_config.dart';
import 'core/di/injectors.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/application/theme_mode_controller.dart';
import 'core/theme/domain/app_theme_mode.dart';
import 'core/widgets/app_splash_placeholder.dart';
import 'core/widgets/notification_fallback_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const bool enableProviderTimelineTracing = bool.fromEnvironment(
    'KOPIM_PROVIDER_TRACE',
    defaultValue: false,
  );
  final ProviderContainer container = ProviderContainer(
    observers: <ProviderObserver>[
      if (enableProviderTimelineTracing && (kDebugMode || kProfileMode))
        const DevToolsProviderObserver(enabled: enableProviderTimelineTracing),
    ],
  );
  unawaited(
    container.read(firebaseInitializationProvider.future).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'main',
          context: ErrorDescription('while prewarming Firebase initialization'),
        ),
      );
    }),
  );

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

/// Отправляет события провайдеров в DevTools Timeline, чтобы понять,
/// что активируется при открытии модалки добавления/редактирования транзакции.
final class DevToolsProviderObserver extends ProviderObserver {
  const DevToolsProviderObserver({this.enabled = false});

  final bool enabled;

  void _trace(String phase, ProviderObserverContext context) {
    if (!enabled) return;
    final String name =
        context.provider.name ?? context.provider.runtimeType.toString();
    developer.Timeline.instantSync(
      'provider:$phase',
      arguments: <String, Object?>{'provider': name},
    );
  }

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    _trace('add', context);
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _trace('update', context);
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {}
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ProviderSubscription<AsyncValue<void>>? _firebaseInitSubscription;

  @override
  void initState() {
    super.initState();
    _firebaseInitSubscription = ref.listenManual<AsyncValue<void>>(
      firebaseInitializationProvider,
      (AsyncValue<void>? previous, AsyncValue<void> next) {
        next.whenOrNull(
          data: (_) =>
              ref.read(appStartupControllerProvider.notifier).initialize(),
        );
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _firebaseInitSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> initializationState = ref.watch(
      firebaseInitializationProvider,
    );

    return initializationState.when(
      data: (_) {
        ref.watch(syncCoordinatorProvider);

        final Locale appLocale = ref.watch(appLocaleProvider);
        final ThemeData lightTheme = ref.watch(appThemeProvider);
        final ThemeData darkTheme = ref.watch(appDarkThemeProvider);
        final AppThemeMode appThemeMode = ref.watch(
          themeModeControllerProvider,
        );
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
          builder: (BuildContext context, Widget? child) {
            return NotificationFallbackListener(child: child);
          },
        );
      },
      loading: () => const _FirebaseInitializationLoadingApp(),
      error: (Object error, StackTrace stackTrace) {
        return _FirebaseInitializationErrorApp(
          error: error,
          onRetry: () {
            ref.invalidate(firebaseInitializationProvider);
          },
        );
      },
    );
  }
}

class _FirebaseInitializationLoadingApp extends ConsumerWidget {
  const _FirebaseInitializationLoadingApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData lightTheme = ref.watch(appThemeProvider);
    final ThemeData darkTheme = ref.watch(appDarkThemeProvider);
    final AppThemeMode appThemeMode = ref.watch(themeModeControllerProvider);
    final ThemeMode themeMode = appThemeMode.toMaterialThemeMode();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const Scaffold(body: AppSplashPlaceholder()),
    );
  }
}

class _FirebaseInitializationErrorApp extends StatelessWidget {
  const _FirebaseInitializationErrorApp({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  String _errorCode(Object error) {
    final int hash = Object.hash(error.runtimeType, error.toString());
    return hash.toUnsigned(32).toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String code = _errorCode(error);
    final bool showDebugMessage =
        kDebugMode ||
        (kIsWeb && Uri.base.queryParameters['firebaseDebug'] == '1');
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Не удалось инициализировать Firebase.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Произошла ошибка. Код: $code',
                    textAlign: TextAlign.center,
                  ),
                  if (showDebugMessage) ...<Widget>[
                    const SizedBox(height: 12),
                    Text('$error', textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Повторить попытку'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
