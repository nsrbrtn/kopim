import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
import 'core/services/web_debug_logger.dart';

final ValueNotifier<String?> _webDebugError = ValueNotifier<String?>(null);
final ValueNotifier<bool> _webDebugOverlayVisible =
    ValueNotifier<bool>(true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureWebErrorReporting();
  if (isWebDebugEnabled) {
    addWebDebugMessage(
      'main: web debug активен, uri=${Uri.base.toString()}',
    );
  }

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

void _configureWebErrorReporting() {
  if (!kIsWeb || Uri.base.queryParameters['firebaseDebug'] != '1') {
    return;
  }
  addWebDebugMessage('main: включен перехват ошибок web');
  final FlutterExceptionHandler? previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    previousOnError?.call(details);
    _webDebugError.value = _formatFlutterError(details);
    addWebDebugMessage('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'main',
        context: ErrorDescription('while handling an uncaught error'),
      ),
    );
    _webDebugError.value = _formatError(error, stackTrace);
    addWebDebugMessage('PlatformDispatcher: $error');
    addWebDebugMessage('$stackTrace');
    return true;
  };
}

String _formatFlutterError(FlutterErrorDetails details) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln(details.exceptionAsString());
  final String? context = details.context?.toDescription();
  if (context != null) {
    buffer.writeln(context);
  }
  if (details.stack != null) {
    buffer.writeln(details.stack);
  }
  return buffer.toString().trim();
}

String _formatError(Object error, StackTrace stackTrace) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln(error);
  buffer.writeln(stackTrace);
  return buffer.toString().trim();
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
        final bool showDebugMessage =
            kIsWeb && Uri.base.queryParameters['firebaseDebug'] == '1';

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
            final Widget resolvedChild = NotificationFallbackListener(
              child: child ?? const SizedBox.shrink(),
            );
            if (!showDebugMessage) {
              return resolvedChild;
            }
            return Stack(
              children: <Widget>[
                resolvedChild,
                const _WebDebugOverlay(),
              ],
            );
          },
        );
      },
      loading: () => const _FirebaseInitializationLoadingApp(),
      error: (Object error, StackTrace stackTrace) {
        return _FirebaseInitializationErrorApp(
          error: error,
          stackTrace: stackTrace,
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
    required this.stackTrace,
    required this.onRetry,
  });

  final Object error;
  final StackTrace stackTrace;
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
        appBar: AppBar(
          title: const Text('Ошибка Firebase'),
          actions: <Widget>[
            if (showDebugMessage)
              ValueListenableBuilder<List<String>>(
                valueListenable: webDebugMessages,
                builder: (BuildContext context, List<String> messages, _) {
                  final String debugDetails = _formatOverlayText(
                    messages,
                    _formatOverlayText(<String>['$error'], '$stackTrace'),
                  );
                  return TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: debugDetails),
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Детали скопированы в буфер.'),
                        ),
                      );
                    },
                    child: const Text('Скопировать'),
                  );
                },
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Не удалось инициализировать Firebase.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Произошла ошибка. Код: $code',
                    textAlign: TextAlign.center,
                  ),
                  if (showDebugMessage) ...<Widget>[
                    const SizedBox(height: 12),
                    ValueListenableBuilder<List<String>>(
                      valueListenable: webDebugMessages,
                      builder:
                          (BuildContext context, List<String> messages, _) {
                        final String debugDetails = _formatOverlayText(
                          messages,
                          _formatOverlayText(
                            <String>['$error'],
                            '$stackTrace',
                          ),
                        );
                        return SelectableText(
                          debugDetails,
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
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

class _WebDebugOverlay extends StatelessWidget {
  const _WebDebugOverlay();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _webDebugOverlayVisible,
      builder: (BuildContext context, bool visible, Widget? child) {
        if (!visible) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder<List<String>>(
          valueListenable: webDebugMessages,
          builder: (BuildContext context, List<String> messages, Widget? child) {
            return ValueListenableBuilder<String?>(
              valueListenable: _webDebugError,
              builder: (BuildContext context, String? value, Widget? child) {
                final String text = _formatOverlayText(messages, value);
                if (text.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxHeight: 260),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _WebDebugOverlayActions(text: text),
                        const SizedBox(height: 8),
                        Flexible(
                          child: SingleChildScrollView(
                            child: SelectableText(
                              text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _WebDebugOverlayActions extends StatelessWidget {
  const _WebDebugOverlayActions({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: <Widget>[
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Текст скопирован в буфер.')),
            );
          },
          child: const Text('Скопировать'),
        ),
        TextButton(
          onPressed: () {
            _webDebugOverlayVisible.value = false;
          },
          child: const Text('Скрыть'),
        ),
      ],
    );
  }
}

String _formatOverlayText(List<String> messages, String? errorText) {
  final StringBuffer buffer = StringBuffer();
  for (final String message in messages) {
    buffer.writeln(message);
  }
  if (errorText != null && errorText.isNotEmpty) {
    if (buffer.isNotEmpty) {
      buffer.writeln('---');
    }
    buffer.writeln(errorText);
  }
  return buffer.toString().trim();
}
