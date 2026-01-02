import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/utils/network_error_utils.dart';

const Map<String, Object> _kOpenRouterProviderConfiguration = <String, Object>{
  'sort': 'latency',
  'order': <String>[
    'ai21',
    'aion-labs',
    'alibaba',
    'amazon-bedrock',
    'amazon-nova',
    'anthropic',
    'arcee-ai',
    'atlas-cloud',
    'avian',
    'azure',
    'baseten',
    'byteplus',
    'black-forest-labs',
    'cerebras',
    'chutes',
    'cirrascale',
    'clarifai',
    'cloudflare',
    'cohere',
    'crusoe',
    'deepinfra',
    'deepseek',
    'featherless',
    'fireworks',
    'friendli',
    'gmicloud',
    'gopomelo',
    'google-vertex',
    'google-ai-studio',
    'groq',
    'hyperbolic',
    'inception',
    'inference-net',
    'infermatic',
    'inflection',
    'liquid',
    'mara',
    'mancer',
    'minimax',
    'modelrun',
    'mistral',
    'modular',
    'moonshotai',
    'morph',
    'ncompass',
    'nebius',
    'nextbit',
    'novita',
    'nvidia',
    'openai',
    'open-inference',
    'parasail',
    'perplexity',
    'phala',
    'relace',
    'sambanova',
    'seed',
    'siliconflow',
    'sourceful',
    'stealth',
    'streamlake',
    'switchpoint',
    'targon',
    'together',
    'venice',
    'wandb',
    'xiaomi',
    'xai',
    'z-ai',
    'fake-provider',
  ],
  'allow_fallbacks': true,
  'data_collection': 'allow',
};

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
  const AiAssistantMessage({
    required this.role,
    required this.content,
    this.toolCalls,
    this.toolCallId,
  });

  factory AiAssistantMessage.system(String content) =>
      AiAssistantMessage(role: 'system', content: content);

  factory AiAssistantMessage.user(String content) =>
      AiAssistantMessage(role: 'user', content: content);

  factory AiAssistantMessage.assistantWithToolCalls(
    List<AiToolCall> toolCalls,
  ) => AiAssistantMessage(role: 'assistant', content: '', toolCalls: toolCalls);

  factory AiAssistantMessage.tool({
    required String toolCallId,
    required String content,
  }) => AiAssistantMessage(
    role: 'tool',
    content: content,
    toolCallId: toolCallId,
  );

  final String role;
  final String content;
  final List<AiToolCall>? toolCalls;
  final String? toolCallId;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'role': role,
      'content': content,
    };
    if (toolCalls != null && toolCalls!.isNotEmpty) {
      json['tool_calls'] = toolCalls!
          .map((AiToolCall call) => call.toJson())
          .toList(growable: false);
    }
    if (toolCallId != null) {
      json['tool_call_id'] = toolCallId;
    }
    return json;
  }
}

class AiToolCall {
  const AiToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  factory AiToolCall.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? function =
        json['function'] as Map<String, dynamic>?;
    return AiToolCall(
      id: json['id'] as String? ?? '',
      name: function?['name'] as String? ?? '',
      arguments: function?['arguments'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': 'function',
    'function': <String, dynamic>{'name': name, 'arguments': arguments},
  };

  final String id;
  final String name;
  final String arguments;
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
    this.toolCalls = const <AiToolCall>[],
  });

  factory AiCompletionMessage.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? delta = json['delta'] as Map<String, dynamic>?;
    final Object? rawContent = json['content'] ?? delta?['content'];
    final String text = _sanitizeContent(_extractContentText(rawContent));
    final List<AiToolCall> toolCalls = _extractToolCalls(json, delta);
    return AiCompletionMessage(
      role: json['role'] as String? ?? delta?['role'] as String? ?? 'assistant',
      content: text,
      rawContent: rawContent,
      toolCalls: toolCalls,
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

  static String _sanitizeContent(String value) {
    if (value.isEmpty) {
      return value;
    }
    final String sanitized = value
        .replaceAll('<|begin_of_sentence|>', '')
        .replaceAll('<|end_of_sentence|>', '')
        .trim();
    return sanitized;
  }

  final String role;
  final String content;
  final Object? rawContent;
  final List<AiToolCall> toolCalls;

  static List<AiToolCall> _extractToolCalls(
    Map<String, dynamic> json,
    Map<String, dynamic>? delta,
  ) {
    final Object? toolCallsRaw = json['tool_calls'] ?? delta?['tool_calls'];
    if (toolCallsRaw is List<dynamic>) {
      return toolCallsRaw
          .whereType<Map<String, dynamic>>()
          .map(AiToolCall.fromJson)
          .toList(growable: false);
    }
    final Object? functionRaw =
        json['function_call'] ?? delta?['function_call'];
    final Map<String, dynamic>? functionCall =
        functionRaw is Map<String, dynamic> ? functionRaw : null;
    if (functionCall != null) {
      final String name = functionCall['name'] as String? ?? '';
      final String arguments = functionCall['arguments'] as String? ?? '';
      if (name.isNotEmpty) {
        return <AiToolCall>[
          AiToolCall(id: 'legacy_call', name: name, arguments: arguments),
        ];
      }
    }
    return const <AiToolCall>[];
  }
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
    List<String> fallbackModels = const <String>[],
  }) : _configLoader = configLoader,
       _analyticsService = analyticsService,
       _loggerService = loggerService,
       _httpClient = httpClient ?? http.Client(),
       _fallbackModels = List<String>.unmodifiable(fallbackModels);

  final Future<GenerativeAiConfig> Function() _configLoader;
  final AnalyticsService _analyticsService;
  final LoggerService _loggerService;
  final http.Client _httpClient;
  final List<String> _fallbackModels;

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
      final Stopwatch stopwatch = Stopwatch();
      try {
        final GenerativeAiConfig resolvedConfig = await _loadConfig();
        _validateConfig(resolvedConfig);
        await _enforceThrottle(resolvedConfig.throttleInterval);
        stopwatch.start();
        final AiCompletionResponse response =
            await _executeWithRetry<AiCompletionResponse>(
              config: resolvedConfig,
              operationName: 'chat_completions',
              operation: (GenerativeAiConfig effectiveConfig) =>
                  _sendChatCompletion(
                    config: effectiveConfig,
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
            'model': resolvedConfig.model,
            'duration_ms': stopwatch.elapsedMilliseconds,
            'prompt_tokens': response.usage?.promptTokens ?? 0,
            'completion_tokens': response.usage?.completionTokens ?? 0,
            'total_tokens': response.usage?.totalTokens ?? 0,
          }),
        );
        if (!completer.isCompleted) {
          completer.complete(
            AiAssistantServiceResult(
              response: response,
              config: resolvedConfig,
              elapsed: stopwatch.elapsed,
            ),
          );
        }
      } on TimeoutException catch (error, stackTrace) {
        _loggerService.logError('Таймаут при обращении к OpenRouter', error);
        _analyticsService.reportError(error, stackTrace);
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      } on AiAssistantException catch (error, stackTrace) {
        _handleKnownException(error, stackTrace);
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      } catch (error, stackTrace) {
        final AiAssistantUnknownException wrapped = AiAssistantUnknownException(
          'Ошибка генерации OpenRouter',
          cause: error,
        );
        _loggerService.logError(wrapped.message, error);
        _analyticsService.reportError(error, stackTrace);
        if (!completer.isCompleted) {
          completer.completeError(wrapped, stackTrace);
        }
      } finally {
        if (stopwatch.isRunning) {
          stopwatch.stop();
        }
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
          final Stopwatch stopwatch = Stopwatch();
          try {
            final GenerativeAiConfig resolvedConfig = await _loadConfig();
            _validateConfig(resolvedConfig);
            await _enforceThrottle(resolvedConfig.throttleInterval);
            stopwatch.start();
            final AiCompletionResponse response =
                await _executeWithRetry<AiCompletionResponse>(
                  config: resolvedConfig,
                  operationName: 'chat_completions_stream',
                  operation: (GenerativeAiConfig effectiveConfig) =>
                      _sendChatCompletion(
                        config: effectiveConfig,
                        messages: messages,
                        requestOptions: requestOptions,
                      ),
                );
            stopwatch.stop();
            _loggerService.logInfo(
              'Потоковый ответ OpenRouter завершён за ${stopwatch.elapsedMilliseconds} мс',
            );
            unawaited(
              _analyticsService
                  .logEvent('ai_assistant_stream_complete', <String, Object?>{
                    'model': resolvedConfig.model,
                    'duration_ms': stopwatch.elapsedMilliseconds,
                  }),
            );
            if (!controller.isClosed) {
              controller.add(
                AiAssistantStreamChunk(
                  response: response,
                  config: resolvedConfig,
                  elapsedSinceStart: stopwatch.elapsed,
                ),
              );
              controller.add(
                AiAssistantStreamChunk(
                  response: null,
                  config: resolvedConfig,
                  elapsedSinceStart: stopwatch.elapsed,
                  isFinal: true,
                ),
              );
            }
          } on TimeoutException catch (error, stackTrace) {
            _loggerService.logError(
              'Таймаут при запуске потокового ответа OpenRouter',
              error,
            );
            _analyticsService.reportError(error, stackTrace);
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          } on AiAssistantException catch (error, stackTrace) {
            _handleKnownException(error, stackTrace);
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          } catch (error, stackTrace) {
            final AiAssistantUnknownException wrapped =
                AiAssistantUnknownException(
                  'Не удалось запустить поток OpenRouter',
                  cause: error,
                );
            _loggerService.logError(wrapped.message, error);
            _analyticsService.reportError(error, stackTrace);
            if (!controller.isClosed) {
              controller.addError(wrapped, stackTrace);
            }
          } finally {
            if (stopwatch.isRunning) {
              stopwatch.stop();
            }
            _lastRequestAt = DateTime.now();
            if (!controller.isClosed) {
              await controller.close();
            }
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
      'provider': _kOpenRouterProviderConfiguration,
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

    final String? requestId = response.headers['x-request-id'];
    _loggerService.logInfo(
      'OpenRouter ответил со статусом ${response.statusCode} (x-request-id=$requestId)',
    );

    if (response.statusCode == 429) {
      throw AiAssistantRateLimitException(
        'Превышен лимит запросов OpenRouter.',
        cause: response.body.isNotEmpty ? response.body : null,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _mapErrorResponse(
        response.statusCode,
        _tryDecodeJson(response.body),
      );
    }

    return _parseCompletionResponse(response);
  }

  AiCompletionResponse _parseCompletionResponse(http.Response response) {
    final Map<String, dynamic> jsonBody =
        _tryDecodeJson(response.body) ?? <String, dynamic>{};
    return AiCompletionResponse.fromJson(jsonBody);
  }

  Map<String, dynamic>? _tryDecodeJson(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      final Object decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException catch (error) {
      _loggerService.logError('Не удалось распарсить ответ OpenRouter', error);
      throw AiAssistantUnknownException(
        'OpenRouter вернул некорректный JSON.',
        cause: error,
      );
    }
    return null;
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
    required Future<T> Function(GenerativeAiConfig effectiveConfig) operation,
  }) async {
    final List<GenerativeAiConfig> candidates = _buildCandidateConfigs(config);
    AiAssistantException? lastError;
    for (final GenerativeAiConfig candidate in candidates) {
      try {
        if (candidate.model != config.model) {
          _loggerService.logInfo(
            'Пробуем запасную модель ${candidate.model} для операции $operationName.',
          );
        }
        return await _retry<T>(
          run: () => operation(candidate),
          operationName: operationName,
          baseDelay: candidate.retryBaseDelay,
          multiplier: candidate.retryMultiplier,
          maxRetries: candidate.maxRetries,
        );
      } on AiAssistantRateLimitException catch (error) {
        lastError = error;
        _loggerService.logInfo(
          'Получен ответ об ограничении. Попытка переключиться на другую модель.',
        );
        continue;
      } on AiAssistantServerException catch (error) {
        lastError = error;
        _loggerService.logError(
          'OpenRouter вернул ошибку сервера для модели ${candidate.model}.',
          error.cause ?? error,
        );
        continue;
      }
    }
    if (lastError != null) {
      throw lastError;
    }
    throw AiAssistantUnknownException(
      'Не удалось выполнить операцию $operationName.',
    );
  }

  Future<T> _retry<T>({
    required Future<T> Function() run,
    required String operationName,
    required Duration baseDelay,
    required double multiplier,
    required int maxRetries,
  }) async {
    int failures = 0;
    Duration delay = baseDelay.inMilliseconds > 0
        ? baseDelay
        : const Duration(milliseconds: 400);
    while (true) {
      try {
        if (failures > 0) {
          _loggerService.logInfo(
            'Повторная попытка $operationName (попытка ${failures + 1})',
          );
        }
        return await run();
      } on TimeoutException {
        rethrow;
      } on AiAssistantRateLimitException catch (error) {
        if (failures >= maxRetries) {
          rethrow;
        }
        await _scheduleRetry(operationName, delay, error);
        failures++;
        delay = _nextDelay(delay, multiplier);
      } on AiAssistantServerException catch (error) {
        if (failures >= maxRetries) {
          rethrow;
        }
        await _scheduleRetry(operationName, delay, error);
        failures++;
        delay = _nextDelay(delay, multiplier);
      } on AiAssistantException {
        rethrow;
      } on http.ClientException catch (error) {
        final AiAssistantUnknownException wrapped = AiAssistantUnknownException(
          'Ошибка HTTP-клиента при обращении к OpenRouter.',
          cause: error,
        );
        if (failures >= maxRetries) {
          throw wrapped;
        }
        await _scheduleRetry(operationName, delay, wrapped);
        failures++;
        delay = _nextDelay(delay, multiplier);
      } catch (error, stackTrace) {
        if (isNetworkSocketException(error)) {
          final AiAssistantServerException wrapped = AiAssistantServerException(
            'Сеть недоступна или OpenRouter не отвечает.',
            cause: error,
          );
          if (failures >= maxRetries) {
            Error.throwWithStackTrace(wrapped, stackTrace);
          }
          await _scheduleRetry(operationName, delay, wrapped);
          failures++;
          delay = _nextDelay(delay, multiplier);
        } else {
          Error.throwWithStackTrace(error, stackTrace);
        }
      }
    }
  }

  Duration _nextDelay(Duration current, double multiplier) {
    final double factor = multiplier.isFinite && multiplier >= 1
        ? multiplier
        : 2;
    final double nextMs = current.inMilliseconds * factor;
    final int clamped = nextMs.isFinite
        ? nextMs.round().clamp(200, 60000)
        : current.inMilliseconds;
    return Duration(milliseconds: clamped);
  }

  List<GenerativeAiConfig> _buildCandidateConfigs(GenerativeAiConfig config) {
    final LinkedHashSet<String> models = LinkedHashSet<String>.from(<String>[
      config.model,
      ..._fallbackModels,
    ]);
    return models
        .map((String model) {
          if (model == config.model) {
            return config;
          }
          return config.copyWith(model: model);
        })
        .toList(growable: false);
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
    if (error is AiAssistantUnknownException &&
        error.cause is FormatException) {
      _loggerService.logInfo(
        'Не удалось распарсить ответ OpenRouter, предпринята попытка очистки контента.',
      );
      return;
    }
    _loggerService.logError(error.message, error.cause ?? error);
    _analyticsService.reportError(error.cause ?? error, stackTrace);
  }
}
