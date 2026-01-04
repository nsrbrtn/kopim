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
import 'core/config/scroll_behavior.dart';
import 'core/di/injectors.dart';
import 'core/navigation/app_router.dart';
import 'core/services/recurring_work_scheduler_mobile.dart';
import 'core/theme/application/theme_mode_controller.dart';
import 'core/theme/domain/app_theme_mode.dart';
import 'core/widgets/app_splash_placeholder.dart';
import 'core/widgets/notification_fallback_listener.dart';
import 'core/widgets/web_responsive_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ensureRecurringWorkSchedulerLinked();

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

    final Locale? appLocale = initializationState.whenOrNull(
      data: (_) => ref.watch(appLocaleProvider),
    );
    final ThemeData lightTheme = ref.watch(appThemeProvider);
    final ThemeData darkTheme = ref.watch(appDarkThemeProvider);
    final AppThemeMode appThemeMode = ref.watch(themeModeControllerProvider);
    final ThemeMode themeMode = appThemeMode.toMaterialThemeMode();

    return MaterialApp.router(
      title: 'Kopim',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: appLocale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: initializationState.when(
        data: (_) {
          ref.watch(syncCoordinatorProvider);
          return ref.watch(appRouterProvider);
        },
        loading: () => _LoadingRouter.instance,
        error: (Object error, StackTrace stackTrace) => _ErrorRouter(
          onRetry: () {
            ref.invalidate(firebaseInitializationProvider);
          },
        ).instance,
      ),
      scrollBehavior: const KopimScrollBehavior(),
      builder: (BuildContext context, Widget? child) {
        return WebResponsiveWrapper(
          child: NotificationFallbackListener(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Фейковый роутер для состояния загрузки, чтобы не пересоздавать MaterialApp.
class _LoadingRouter {
  _LoadingRouter._();
  static final GoRouter instance = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: AppSplashPlaceholder()),
      ),
    ],
  );
}

/// Роутер для состояния ошибки.
class _ErrorRouter {
  _ErrorRouter({required this.onRetry});
  final VoidCallback onRetry;

  late final GoRouter instance = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
      ),
    ],
  );
}
