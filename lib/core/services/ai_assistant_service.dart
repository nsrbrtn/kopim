import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';

/// Результат синхронного вызова модели Gemini.
class AiAssistantServiceResult {
  AiAssistantServiceResult({
    required this.response,
    required this.config,
    required this.elapsed,
  });

  final GenerateContentResponse response;
  final GenerativeAiConfig config;
  final Duration elapsed;
}

/// Элемент потокового ответа от модели Gemini.
class AiAssistantStreamChunk {
  AiAssistantStreamChunk({
    required this.config,
    required this.elapsedSinceStart,
    this.response,
    this.isFinal = false,
  });

  final GenerateContentResponse? response;
  final GenerativeAiConfig config;
  final Duration elapsedSinceStart;
  final bool isFinal;
}

/// Сервис-обёртка над Gemini, обеспечивающая троттлинг, таймауты и журналирование.
class AiAssistantService {
  AiAssistantService({
    required Future<GenerativeAiConfig> Function() configLoader,
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
  }) : _configLoader = configLoader,
       _analyticsService = analyticsService,
       _loggerService = loggerService;

  final Future<GenerativeAiConfig> Function() _configLoader;
  final AnalyticsService _analyticsService;
  final LoggerService _loggerService;

  GenerativeModel? _model;
  GenerativeAiConfig? _cachedConfig;
  String? _cachedApiKey;
  DateTime? _lastRequestAt;
  Future<void> _requestQueue = Future<void>.value();

  /// Выполняет генерацию ответа в одном запросе.
  Future<AiAssistantServiceResult> generateAnswer({
    required Iterable<Content> prompt,
    GenerationConfig? generationConfig,
    List<SafetySetting>? safetySettings,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) {
    final Completer<AiAssistantServiceResult> completer =
        Completer<AiAssistantServiceResult>();
    _requestQueue = _requestQueue.then((_) async {
      final GenerativeAiConfig config = await _loadConfig();
      await _enforceThrottle(config.throttleInterval);
      final Stopwatch stopwatch = Stopwatch();
      try {
        stopwatch.start();
        final GenerativeModel model = await _ensureModel(config);
        final GenerateContentResponse response = await model
            .generateContent(
              prompt,
              generationConfig: generationConfig,
              safetySettings: safetySettings,
              tools: tools,
              toolConfig: toolConfig,
            )
            .timeout(
              config.requestTimeout,
              onTimeout: () => throw TimeoutException(
                'Время ожидания ответа Gemini истекло.',
              ),
            );
        stopwatch.stop();
        _loggerService.logInfo(
          'Gemini вернул ответ за ${stopwatch.elapsedMilliseconds} мс',
        );
        await _analyticsService
            .logEvent('ai_assistant_generate', <String, Object?>{
              'model': config.model,
              'duration_ms': stopwatch.elapsedMilliseconds,
              'prompt_tokens': response.usageMetadata?.promptTokenCount ?? 0,
              'completion_tokens':
                  response.usageMetadata?.candidatesTokenCount ?? 0,
              'total_tokens': response.usageMetadata?.totalTokenCount ?? 0,
            });
        completer.complete(
          AiAssistantServiceResult(
            response: response,
            config: config,
            elapsed: stopwatch.elapsed,
          ),
        );
      } on TimeoutException catch (error, stackTrace) {
        if (stopwatch.isRunning) {
          stopwatch.stop();
        }
        _loggerService.logError('Таймаут при обращении к Gemini', error);
        _analyticsService.reportError(error, stackTrace);
        completer.completeError(error, stackTrace);
      } catch (error, stackTrace) {
        if (stopwatch.isRunning) {
          stopwatch.stop();
        }
        _loggerService.logError('Ошибка генерации Gemini', error);
        _analyticsService.reportError(error, stackTrace);
        completer.completeError(error, stackTrace);
      } finally {
        _lastRequestAt = DateTime.now();
      }
    });
    return completer.future;
  }

  /// Возвращает поток частичных ответов от Gemini.
  Stream<AiAssistantStreamChunk> streamAnswer({
    required Iterable<Content> prompt,
    GenerationConfig? generationConfig,
    List<SafetySetting>? safetySettings,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) {
    late StreamController<AiAssistantStreamChunk> controller;
    controller = StreamController<AiAssistantStreamChunk>(
      onListen: () {
        _requestQueue = _requestQueue.then((_) async {
          final GenerativeAiConfig config = await _loadConfig();
          await _enforceThrottle(config.throttleInterval);
          final Stopwatch stopwatch = Stopwatch()..start();
          StreamSubscription<GenerateContentResponse>? subscription;
          try {
            final GenerativeModel model = await _ensureModel(config);
            final Stream<GenerateContentResponse> source = model
                .generateContentStream(
                  prompt,
                  generationConfig: generationConfig,
                  safetySettings: safetySettings,
                  tools: tools,
                  toolConfig: toolConfig,
                )
                .timeout(
                  config.requestTimeout,
                  onTimeout: (EventSink<GenerateContentResponse> sink) =>
                      sink.addError(
                        TimeoutException(
                          'Время ожидания потокового ответа Gemini истекло.',
                        ),
                      ),
                );
            subscription = source.listen(
              (GenerateContentResponse response) {
                controller.add(
                  AiAssistantStreamChunk(
                    response: response,
                    config: config,
                    elapsedSinceStart: stopwatch.elapsed,
                  ),
                );
              },
              onError: (Object error, StackTrace stackTrace) {
                if (stopwatch.isRunning) {
                  stopwatch.stop();
                }
                _loggerService.logError(
                  'Ошибка потокового ответа Gemini',
                  error,
                );
                _analyticsService.reportError(error, stackTrace);
                controller.addError(error, stackTrace);
                controller.close();
              },
              onDone: () async {
                if (stopwatch.isRunning) {
                  stopwatch.stop();
                }
                _loggerService.logInfo(
                  'Потоковый ответ Gemini завершён за ${stopwatch.elapsedMilliseconds} мс',
                );
                await _analyticsService
                    .logEvent('ai_assistant_stream_complete', <String, Object?>{
                      'model': config.model,
                      'duration_ms': stopwatch.elapsedMilliseconds,
                    });
                controller.add(
                  AiAssistantStreamChunk(
                    response: null,
                    config: config,
                    elapsedSinceStart: stopwatch.elapsed,
                    isFinal: true,
                  ),
                );
                await controller.close();
              },
              cancelOnError: false,
            );
          } on TimeoutException catch (error, stackTrace) {
            if (stopwatch.isRunning) {
              stopwatch.stop();
            }
            _loggerService.logError(
              'Таймаут при запуске потокового ответа Gemini',
              error,
            );
            _analyticsService.reportError(error, stackTrace);
            controller.addError(error, stackTrace);
            await controller.close();
          } catch (error, stackTrace) {
            if (stopwatch.isRunning) {
              stopwatch.stop();
            }
            _loggerService.logError('Не удалось запустить поток Gemini', error);
            _analyticsService.reportError(error, stackTrace);
            controller.addError(error, stackTrace);
            await controller.close();
          } finally {
            _lastRequestAt = DateTime.now();
            controller.onCancel = () async {
              await subscription?.cancel();
            };
          }
        });
      },
    );
    return controller.stream;
  }

  Future<GenerativeAiConfig> _loadConfig() async {
    final GenerativeAiConfig config = await _configLoader();
    _cachedConfig = config;
    return config;
  }

  Future<GenerativeModel> _ensureModel(GenerativeAiConfig config) async {
    final String? apiKey = config.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError(
        'API-ключ Gemini не настроен. Укажите ключ через Remote Config или переменные окружения.',
      );
    }
    final bool needsRebuild =
        _model == null ||
        _cachedApiKey != apiKey ||
        (_cachedConfig?.model != config.model);
    if (needsRebuild) {
      _model = GenerativeModel(model: config.model, apiKey: apiKey);
      _cachedApiKey = apiKey;
    }
    _cachedConfig = config;
    return _model!;
  }

  Future<void> _enforceThrottle(Duration minInterval) async {
    final DateTime now = DateTime.now();
    final DateTime? last = _lastRequestAt;
    if (last == null) {
      return;
    }
    final Duration elapsed = now.difference(last);
    if (elapsed < minInterval) {
      final Duration waitDuration = minInterval - elapsed;
      _loggerService.logInfo(
        'Троттлинг запроса к Gemini: ожидание ${waitDuration.inMilliseconds} мс',
      );
      await Future<void>.delayed(waitDuration);
    }
  }
}
