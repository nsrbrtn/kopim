import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/utils/timezone_utils.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'core/application/app_startup_controller.dart';
import 'core/config/app_config.dart';
import 'core/di/injectors.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/application/theme_mode_controller.dart';
import 'core/theme/domain/app_theme_mode.dart';
import 'core/widgets/notification_fallback_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String timeZoneId = resolveCurrentTimeZoneId();
  tz.setLocalLocation(tz.getLocation(timeZoneId));

  const bool enableProviderTimelineTracing = true;
  final ProviderContainer container = ProviderContainer(
    observers: <ProviderObserver>[
      if (kDebugMode || kProfileMode)
        DevToolsProviderObserver(enabled: enableProviderTimelineTracing),
    ],
  );
  unawaited(container.read(firebaseInitializationProvider.future));

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

class _FirebaseInitializationLoadingApp extends StatelessWidget {
  const _FirebaseInitializationLoadingApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
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
                  Text('$error', textAlign: TextAlign.center),
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
