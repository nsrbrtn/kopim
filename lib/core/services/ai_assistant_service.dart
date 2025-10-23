import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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

/// Ошибка на стороне OpenRouter/модели DeepSeek.
class AiAssistantServerException extends AiAssistantException {
  AiAssistantServerException(super.message, {super.cause});
}

/// Нераспознанная ошибка OpenRouter.
class AiAssistantUnknownException extends AiAssistantException {
  AiAssistantUnknownException(super.message, {super.cause});
}

/// Сообщение для отправки в OpenRouter.
class AiAssistantMessage {
  const AiAssistantMessage({required this.role, required this.content});

  factory AiAssistantMessage.system(String content) =>
      AiAssistantMessage(role: 'system', content: content);

  factory AiAssistantMessage.user(String content) =>
      AiAssistantMessage(role: 'user', content: content);

  final String role;
  final String content;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'role': role,
    'content': content,
  };
}

/// Данные об использовании токенов из ответа OpenRouter.
class AiCompletionUsage {
  AiCompletionUsage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
  });

  factory AiCompletionUsage.fromJson(Map<String, dynamic> json) {
    return AiCompletionUsage(
      promptTokens: json['prompt_tokens'] as int?,
      completionTokens: json['completion_tokens'] as int?,
      totalTokens: json['total_tokens'] as int?,
    );
  }

  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
}

/// Сообщение ассистента в ответе OpenRouter.
class AiCompletionMessage {
  AiCompletionMessage({
    required this.role,
    required this.content,
    this.rawContent,
  });

  factory AiCompletionMessage.fromJson(Map<String, dynamic> json) {
    final Object? rawContent = json['content'];
    final String text = _extractContentText(rawContent);
    return AiCompletionMessage(
      role: json['role'] as String? ?? 'assistant',
      content: text,
      rawContent: rawContent,
    );
  }

  static String _extractContentText(Object? rawContent) {
    if (rawContent is String) {
      return rawContent;
    }
    if (rawContent is List<dynamic>) {
      final StringBuffer buffer = StringBuffer();
      for (final dynamic element in rawContent) {
        if (element is Map<String, dynamic>) {
          final Object? text = element['text'] ?? element['content'];
          if (text is String && text.isNotEmpty) {
            buffer.write(text);
            if (!text.endsWith(' ')) {
              buffer.write(' ');
            }
          }
        }
      }
      return buffer.toString().trim();
    }
    return '';
  }

  final String role;
  final String content;
  final Object? rawContent;
}

/// Вариант ответа из OpenRouter.
class AiCompletionChoice {
  AiCompletionChoice({this.index, this.finishReason, this.message});

  factory AiCompletionChoice.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? messageJson =
        json['message'] as Map<String, dynamic>?;
    return AiCompletionChoice(
      index: json['index'] as int?,
      finishReason: json['finish_reason'] as String?,
      message: messageJson != null
          ? AiCompletionMessage.fromJson(messageJson)
          : null,
    );
  }

  final int? index;
  final String? finishReason;
  final AiCompletionMessage? message;
}

/// Ответ OpenRouter на запрос completions.
class AiCompletionResponse {
  AiCompletionResponse({
    required this.id,
    required this.choices,
    required this.raw,
    this.model,
    this.usage,
  });

  factory AiCompletionResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> choiceList =
        (json['choices'] as List<dynamic>?) ?? const <dynamic>[];
    return AiCompletionResponse(
      id: json['id'] as String? ?? '',
      model: json['model'] as String?,
      usage: json['usage'] is Map<String, dynamic>
          ? AiCompletionUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      choices: choiceList
          .whereType<Map<String, dynamic>>()
          .map(AiCompletionChoice.fromJson)
          .toList(growable: false),
      raw: json,
    );
  }

  final String id;
  final String? model;
  final List<AiCompletionChoice> choices;
  final AiCompletionUsage? usage;
  final Map<String, dynamic> raw;
}

/// Результат синхронного вызова модели OpenRouter.
class AiAssistantServiceResult {
  AiAssistantServiceResult({
    required this.response,
    required this.config,
    required this.elapsed,
  });

  final AiCompletionResponse response;
  final GenerativeAiConfig config;
  final Duration elapsed;
}

/// Элемент потокового ответа от модели OpenRouter.
class AiAssistantStreamChunk {
  AiAssistantStreamChunk({
    required this.config,
    required this.elapsedSinceStart,
    this.response,
    this.isFinal = false,
  });

  final AiCompletionResponse? response;
  final GenerativeAiConfig config;
  final Duration elapsedSinceStart;
  final bool isFinal;
}

/// Сервис-обёртка над OpenRouter, обеспечивающая троттлинг, таймауты и журналирование.
class AiAssistantService {
  AiAssistantService({
    required Future<GenerativeAiConfig> Function() configLoader,
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
    http.Client? httpClient,
  }) : _configLoader = configLoader,
       _analyticsService = analyticsService,
       _loggerService = loggerService,
       _httpClient = httpClient ?? http.Client();

  final Future<GenerativeAiConfig> Function() _configLoader;
  final AnalyticsService _analyticsService;
  final LoggerService _loggerService;
  final http.Client _httpClient;

  DateTime? _lastRequestAt;
  Future<void> _requestQueue = Future<void>.value();

  /// Выполняет генерацию ответа в одном запросе.
  Future<AiAssistantServiceResult> generateAnswer({
    required Iterable<AiAssistantMessage> messages,
    Map<String, dynamic>? requestOptions,
  }) {
    final Completer<AiAssistantServiceResult> completer =
        Completer<AiAssistantServiceResult>();
    _requestQueue = _requestQueue.then((_) async {
      final GenerativeAiConfig config = await _loadConfig();
      _validateConfig(config);
      await _enforceThrottle(config.throttleInterval);
      final Stopwatch stopwatch = Stopwatch()..start();
      try {
        final AiCompletionResponse response =
            await _executeWithRetry<AiCompletionResponse>(
              config: config,
              operationName: 'chat_completions',
              operation: () => _sendChatCompletion(
                config: config,
                messages: messages,
                requestOptions: requestOptions,
              ),
            );
        stopwatch.stop();
        _loggerService.logInfo(
          'OpenRouter вернул ответ за ${stopwatch.elapsedMilliseconds} мс',
        );
        unawaited(
          _analyticsService.logEvent('ai_assistant_generate', <String, Object?>{
            'model': config.model,
            'duration_ms': stopwatch.elapsedMilliseconds,
            'prompt_tokens': response.usage?.promptTokens ?? 0,
            'completion_tokens': response.usage?.completionTokens ?? 0,
            'total_tokens': response.usage?.totalTokens ?? 0,
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
        _loggerService.logError('Таймаут при обращении к OpenRouter', error);
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
        final AiAssistantUnknownException wrapped = AiAssistantUnknownException(
          'Ошибка генерации OpenRouter',
          cause: error,
        );
        _loggerService.logError(wrapped.message, error);
        _analyticsService.reportError(error, stackTrace);
        completer.completeError(wrapped, stackTrace);
      } finally {
        _lastRequestAt = DateTime.now();
      }
    });
    return completer.future;
  }

  /// Возвращает поток частичных ответов от OpenRouter (эмуляция на базе одиночного запроса).
  Stream<AiAssistantStreamChunk> streamAnswer({
    required Iterable<AiAssistantMessage> messages,
    Map<String, dynamic>? requestOptions,
  }) {
    late StreamController<AiAssistantStreamChunk> controller;
    controller = StreamController<AiAssistantStreamChunk>(
      onListen: () {
        _requestQueue = _requestQueue.then((_) async {
          final GenerativeAiConfig config = await _loadConfig();
          _validateConfig(config);
          await _enforceThrottle(config.throttleInterval);
          final Stopwatch stopwatch = Stopwatch()..start();
          try {
            final AiCompletionResponse response =
                await _executeWithRetry<AiCompletionResponse>(
                  config: config,
                  operationName: 'chat_completions_stream',
                  operation: () => _sendChatCompletion(
                    config: config,
                    messages: messages,
                    requestOptions: requestOptions,
                  ),
                );
            stopwatch.stop();
            _loggerService.logInfo(
              'Потоковый ответ OpenRouter завершён за ${stopwatch.elapsedMilliseconds} мс',
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
                response: response,
                config: config,
                elapsedSinceStart: stopwatch.elapsed,
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
          } on TimeoutException catch (error, stackTrace) {
            if (stopwatch.isRunning) {
              stopwatch.stop();
            }
            _loggerService.logError(
              'Таймаут при запуске потокового ответа OpenRouter',
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
            final AiAssistantUnknownException wrapped =
                AiAssistantUnknownException(
                  'Не удалось запустить поток OpenRouter',
                  cause: error,
                );
            _loggerService.logError(wrapped.message, error);
            _analyticsService.reportError(error, stackTrace);
            controller.addError(wrapped, stackTrace);
            await controller.close();
          } finally {
            _lastRequestAt = DateTime.now();
          }
        });
      },
    );
    return controller.stream;
  }

  Future<GenerativeAiConfig> _loadConfig() async {
    final GenerativeAiConfig config = await _configLoader();
    return config;
  }

  void _validateConfig(GenerativeAiConfig config) {
    if (!config.isEnabled) {
      throw AiAssistantDisabledException(
        'ИИ-ассистент временно отключён в конфигурации.',
      );
    }
    final String? apiKey = config.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw AiAssistantConfigurationException(
        'API-ключ OpenRouter не настроен. Укажите ключ через Remote Config или переменные окружения.',
      );
    }
  }

  Future<AiCompletionResponse> _sendChatCompletion({
    required GenerativeAiConfig config,
    required Iterable<AiAssistantMessage> messages,
    Map<String, dynamic>? requestOptions,
  }) async {
    final Uri uri = Uri.parse('${config.baseUrl}/chat/completions');
    final Map<String, dynamic> payload = <String, dynamic>{
      'model': config.model,
      'messages': messages
          .map((AiAssistantMessage message) => message.toJson())
          .toList(growable: false),
      if (requestOptions != null) ...requestOptions,
    };

    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${config.apiKey}',
    };
    if (config.referer != null && config.referer!.isNotEmpty) {
      headers['HTTP-Referer'] = config.referer!;
    }
    if (config.appTitle != null && config.appTitle!.isNotEmpty) {
      headers['X-Title'] = config.appTitle!;
    }

    final http.Response response = await _httpClient
        .post(uri, headers: headers, body: jsonEncode(payload))
        .timeout(
          config.requestTimeout,
          onTimeout: () => throw TimeoutException(
            'Время ожидания ответа OpenRouter истекло.',
          ),
        );

    return _parseCompletionResponse(response);
  }

  AiCompletionResponse _parseCompletionResponse(http.Response response) {
    Map<String, dynamic>? jsonBody;
    if (response.body.isNotEmpty) {
      try {
        final Object decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          jsonBody = decoded;
        }
      } on FormatException catch (error) {
        throw AiAssistantUnknownException(
          'OpenRouter вернул некорректный JSON.',
          cause: error,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AiCompletionResponse.fromJson(jsonBody ?? <String, dynamic>{});
    }

    throw _mapErrorResponse(response.statusCode, jsonBody);
  }

  AiAssistantException _mapErrorResponse(
    int statusCode,
    Map<String, dynamic>? body,
  ) {
    final Map<String, dynamic>? error = body?['error'] as Map<String, dynamic>?;
    final String? message = (error?['message'] ?? body?['message']) as String?;
    final String normalized = (message ?? '').toLowerCase();

    if (statusCode == 401 || statusCode == 403) {
      return AiAssistantConfigurationException(
        message ?? 'OpenRouter вернул ошибку авторизации.',
        cause: body,
      );
    }
    if (statusCode == 429 ||
        normalized.contains('rate') ||
        normalized.contains('quota') ||
        normalized.contains('limit')) {
      return AiAssistantRateLimitException(
        message ??
            'Превышен лимит запросов OpenRouter. Попробуйте снова чуть позже.',
        cause: body,
      );
    }
    if (statusCode >= 500 || normalized.contains('unavailable')) {
      return AiAssistantServerException(
        message ??
            'Сервер OpenRouter временно недоступен. Попробуйте повторить запрос позже.',
        cause: body,
      );
    }
    return AiAssistantUnknownException(
      message != null && message.isNotEmpty
          ? 'OpenRouter вернул ошибку: $message'
          : 'OpenRouter вернул ошибку с кодом $statusCode.',
      cause: body,
    );
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
        'Троттлинг запроса к OpenRouter: ожидание ${waitDuration.inMilliseconds} мс',
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
      } on AiAssistantException catch (error) {
        if (!_isRetryableException(error, attempt, config.maxRetries)) {
          rethrow;
        }
        final Duration delay = config.retryDelayForAttempt(attempt);
        await _scheduleRetry(operationName, delay, error);
        attempt++;
      } on SocketException catch (error) {
        final AiAssistantServerException wrapped = AiAssistantServerException(
          'Сеть недоступна или OpenRouter не отвечает.',
          cause: error,
        );
        if (!_isRetryableException(wrapped, attempt, config.maxRetries)) {
          throw wrapped;
        }
        final Duration delay = config.retryDelayForAttempt(attempt);
        await _scheduleRetry(operationName, delay, wrapped);
        attempt++;
      } on http.ClientException catch (error) {
        final AiAssistantUnknownException wrapped = AiAssistantUnknownException(
          'Ошибка HTTP-клиента при обращении к OpenRouter.',
          cause: error,
        );
        if (!_isRetryableException(wrapped, attempt, config.maxRetries)) {
          throw wrapped;
        }
        final Duration delay = config.retryDelayForAttempt(attempt);
        await _scheduleRetry(operationName, delay, wrapped);
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
}
