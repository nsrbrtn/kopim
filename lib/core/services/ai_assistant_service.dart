import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';

/// Базовое исключение сервиса ассистента.
class AiAssistantException implements Exception {
  AiAssistantException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Ошибка неверной конфигурации (API-ключ, регион и т.п.).
class AiAssistantConfigurationException extends AiAssistantException {
  AiAssistantConfigurationException(super.message, {super.cause});
}

/// Флаг отключения ассистента.
class AiAssistantDisabledException extends AiAssistantException {
  AiAssistantDisabledException(super.message);
}

/// Ошибка превышения лимитов API.
class AiAssistantRateLimitException extends AiAssistantException {
  AiAssistantRateLimitException(super.message, {super.cause});
}

/// Ошибка на стороне сервиса Gemini.
class AiAssistantServerException extends AiAssistantException {
  AiAssistantServerException(super.message, {super.cause});
}

/// Нераспознанная ошибка Gemini.
class AiAssistantUnknownException extends AiAssistantException {
  AiAssistantUnknownException(super.message, {super.cause});
}

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
      final Stopwatch stopwatch = Stopwatch()..start();
      try {
        final GenerateContentResponse response =
            await _executeWithRetry<GenerateContentResponse>(
              config: config,
              operationName: 'generateContent',
              operation: () async {
                final GenerativeModel model = await _ensureModel(config);
                return model
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
              },
            );
        stopwatch.stop();
        _loggerService.logInfo(
          'Gemini вернул ответ за ${stopwatch.elapsedMilliseconds} мс',
        );
        unawaited(
          _analyticsService.logEvent('ai_assistant_generate', <String, Object?>{
            'model': config.model,
            'duration_ms': stopwatch.elapsedMilliseconds,
            'prompt_tokens': response.usageMetadata?.promptTokenCount ?? 0,
            'completion_tokens':
                response.usageMetadata?.candidatesTokenCount ?? 0,
            'total_tokens': response.usageMetadata?.totalTokenCount ?? 0,
          }),
        );
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
      } on AiAssistantException catch (error, stackTrace) {
        if (stopwatch.isRunning) {
          stopwatch.stop();
        }
        _handleKnownException(error, stackTrace);
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
            await _executeWithRetry<void>(
              config: config,
              operationName: 'generateContentStream',
              operation: () async {
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
                    final Object mapped = _wrapStreamError(error);
                    if (mapped is AiAssistantException) {
                      _handleKnownException(mapped, stackTrace);
                    } else if (mapped is TimeoutException) {
                      _loggerService.logError(
                        'Таймаут потокового ответа Gemini',
                        error,
                      );
                      _analyticsService.reportError(error, stackTrace);
                    } else {
                      _loggerService.logError(
                        'Ошибка потокового ответа Gemini',
                        mapped,
                      );
                      _analyticsService.reportError(mapped, stackTrace);
                    }
                    controller.addError(mapped, stackTrace);
                    controller.close();
                  },
                  onDone: () async {
                    if (stopwatch.isRunning) {
                      stopwatch.stop();
                    }
                    _loggerService.logInfo(
                      'Потоковый ответ Gemini завершён за ${stopwatch.elapsedMilliseconds} мс',
                    );
                    unawaited(
                      _analyticsService.logEvent(
                        'ai_assistant_stream_complete',
                        <String, Object?>{
                          'model': config.model,
                          'duration_ms': stopwatch.elapsedMilliseconds,
                        },
                      ),
                    );
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
              },
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
          } on AiAssistantException catch (error, stackTrace) {
            if (stopwatch.isRunning) {
              stopwatch.stop();
            }
            _handleKnownException(error, stackTrace);
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
    if (!config.isEnabled) {
      throw AiAssistantDisabledException(
        'ИИ-ассистент временно отключён в конфигурации.',
      );
    }
    final String? apiKey = config.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw AiAssistantConfigurationException(
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

  Future<T> _executeWithRetry<T>({
    required GenerativeAiConfig config,
    required String operationName,
    required Future<T> Function() operation,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        if (attempt > 0) {
          _loggerService.logInfo(
            'Повторная попытка $operationName (попытка ${attempt + 1})',
          );
        }
        return await operation();
      } on TimeoutException {
        rethrow;
      } on InvalidApiKey catch (error) {
        throw AiAssistantConfigurationException(
          'Получен неверный API-ключ Gemini.',
          cause: error,
        );
      } on UnsupportedUserLocation catch (error) {
        throw AiAssistantConfigurationException(
          'Регион пользователя не поддерживается для Gemini.',
          cause: error,
        );
      } on GenerativeAIException catch (error) {
        final AiAssistantException mapped = _mapGenerativeError(error);
        if (!_isRetryableException(mapped, attempt, config.maxRetries)) {
          throw mapped;
        }
        final Duration delay = config.retryDelayForAttempt(attempt);
        await _scheduleRetry(operationName, delay, mapped);
        attempt++;
      }
    }
  }

  Future<void> _scheduleRetry(
    String operationName,
    Duration delay,
    AiAssistantException reason,
  ) async {
    _loggerService.logInfo(
      'Повторная попытка $operationName через ${delay.inMilliseconds} мс из-за: ${reason.message}',
    );
    unawaited(
      _analyticsService.logEvent('ai_assistant_retry', <String, Object?>{
        'operation': operationName,
        'delay_ms': delay.inMilliseconds,
        'reason': reason.runtimeType.toString(),
      }),
    );
    await Future<void>.delayed(delay);
  }

  bool _isRetryableException(
    AiAssistantException exception,
    int attempt,
    int maxRetries,
  ) {
    if (attempt >= maxRetries) {
      return false;
    }
    return exception is AiAssistantRateLimitException ||
        exception is AiAssistantServerException;
  }

  AiAssistantException _mapGenerativeError(GenerativeAIException error) {
    final String normalized = error.message.toLowerCase();
    if (_isRateLimitMessage(normalized)) {
      return AiAssistantRateLimitException(
        'Превышен лимит запросов Gemini. Попробуйте снова чуть позже.',
        cause: error,
      );
    }
    if (_isServerMessage(normalized)) {
      return AiAssistantServerException(
        'Сервер Gemini временно недоступен. Попробуйте повторить запрос позже.',
        cause: error,
      );
    }
    return AiAssistantUnknownException(
      'Gemini вернул ошибку: ${error.message}',
      cause: error,
    );
  }

  bool _isRateLimitMessage(String message) {
    return message.contains('429') ||
        message.contains('exceed') ||
        message.contains('quota') ||
        message.contains('exhaust');
  }

  bool _isServerMessage(String message) {
    return message.contains('500') ||
        message.contains('503') ||
        message.contains('unavailable') ||
        message.contains('internal') ||
        message.contains('server error');
  }

  void _handleKnownException(
    AiAssistantException error,
    StackTrace stackTrace,
  ) {
    if (error is AiAssistantDisabledException) {
      _loggerService.logInfo(error.message);
      return;
    }
    if (error is AiAssistantRateLimitException) {
      _loggerService.logInfo(error.message);
      unawaited(
        _analyticsService.logEvent('ai_assistant_rate_limit', <String, Object?>{
          'reason': error.message,
        }),
      );
      return;
    }
    if (error is AiAssistantServerException) {
      _loggerService.logError(error.message, error.cause);
      _analyticsService.reportError(error.cause ?? error, stackTrace);
      return;
    }
    if (error is AiAssistantConfigurationException) {
      _loggerService.logError(error.message, error.cause ?? error);
      _analyticsService.reportError(error.cause ?? error, stackTrace);
      return;
    }
    _loggerService.logError(error.message, error.cause ?? error);
    _analyticsService.reportError(error.cause ?? error, stackTrace);
  }

  Object _wrapStreamError(Object error) {
    if (error is AiAssistantException) {
      return error;
    }
    if (error is GenerativeAIException) {
      return _mapGenerativeError(error);
    }
    return error;
  }
}
