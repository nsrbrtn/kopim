import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/ai/domain/entities/ai_llm_result_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_user_query_entity.dart';
import 'package:kopim/features/ai/domain/use_cases/ask_financial_assistant_use_case.dart';
import 'package:kopim/features/ai/presentation/models/assistant_filters.dart';
import 'package:kopim/features/ai/presentation/models/assistant_message.dart';
import 'package:kopim/features/ai/presentation/models/assistant_session_state.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'assistant_session_controller.g.dart';

const String _kOfflineUserFallbackId = 'assistant-offline-user';
const int _kDialogContextLimit = 10;

@Riverpod(keepAlive: true)
class AssistantSessionController extends _$AssistantSessionController {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Future<void> _sendQueue = Future<void>.value();

  @override
  AssistantSessionState build() {
    final Connectivity connectivity = ref.watch(connectivityProvider);
    unawaited(_observeConnectivity(connectivity));
    ref.onDispose(() => _connectivitySubscription?.cancel());
    return const AssistantSessionState();
  }

  Future<void> sendMessage(
    String rawText, {
    AiQueryIntent? intentOverride,
    Set<AssistantFilter> additionalFilters = const <AssistantFilter>{},
  }) async {
    final String text = rawText.trim();
    if (text.isEmpty) {
      return;
    }

    if (!ref.mounted) {
      return;
    }
    final bool offline = state.isOffline || await _isCurrentlyOffline();
    if (!ref.mounted) {
      return;
    }
    final Uuid uuid = ref.read(uuidGeneratorProvider);
    final Set<AssistantFilter> effectiveFilters = <AssistantFilter>{
      ...state.activeFilters,
      ...additionalFilters,
    };
    final AssistantMessage userMessage = AssistantMessage(
      id: uuid.v4(),
      author: AssistantMessageAuthor.user,
      content: text,
      createdAt: DateTime.now(),
      deliveryStatus: offline
          ? AssistantMessageDeliveryStatus.pending
          : AssistantMessageDeliveryStatus.sending,
      contextFilters: effectiveFilters,
    );

    state = state.copyWith(
      messages: <AssistantMessage>[...state.messages, userMessage],
      lastError: AssistantErrorType.none,
    );

    if (offline) {
      return;
    }

    _sendQueue = _sendQueue.then((_) async {
      await _processUserMessage(
        userMessage: userMessage,
        intentOverride: intentOverride,
      );
    });

    await _sendQueue;
  }

  Future<void> retryPendingMessages() async {
    if (!ref.mounted) {
      return;
    }
    if (state.isOffline || await _isCurrentlyOffline()) {
      return;
    }
    if (!ref.mounted) {
      return;
    }

    final List<AssistantMessage> candidates = state.messages
        .where(
          (AssistantMessage message) =>
              message.author == AssistantMessageAuthor.user &&
              (message.deliveryStatus ==
                      AssistantMessageDeliveryStatus.pending ||
                  message.deliveryStatus ==
                      AssistantMessageDeliveryStatus.failed),
        )
        .toList(growable: false);

    for (final AssistantMessage message in candidates) {
      await retryMessage(message.id);
    }
  }

  Future<void> retryMessage(String messageId) async {
    if (!ref.mounted) {
      return;
    }
    if (state.isOffline || await _isCurrentlyOffline()) {
      return;
    }
    if (!ref.mounted) {
      return;
    }

    final AssistantMessage? existing = state.messages.firstWhereOrNull(
      (AssistantMessage message) => message.id == messageId,
    );
    if (existing == null || existing.author != AssistantMessageAuthor.user) {
      return;
    }

    final AssistantMessage updatedMessage = existing.copyWith(
      deliveryStatus: AssistantMessageDeliveryStatus.sending,
    );
    state = state.copyWith(
      messages: _replaceMessage(messageId, updatedMessage),
      lastError: AssistantErrorType.none,
    );

    await _processUserMessage(userMessage: updatedMessage);
  }

  void toggleFilter(AssistantFilter filter) {
    final Set<AssistantFilter> updatedFilters = Set<AssistantFilter>.from(
      state.activeFilters,
    );
    if (!updatedFilters.add(filter)) {
      updatedFilters.remove(filter);
    }
    state = state.copyWith(activeFilters: updatedFilters);
  }

  void clearFilters() {
    if (state.activeFilters.isEmpty) {
      return;
    }
    state = state.copyWith(activeFilters: const <AssistantFilter>{});
  }

  Future<void> _observeConnectivity(Connectivity connectivity) async {
    final List<ConnectivityResult> initial = await connectivity
        .checkConnectivity();
    if (!ref.mounted) {
      return;
    }
    _updateOfflineState(initial);
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (!ref.mounted) {
        return;
      }
      _updateOfflineState(results);
      if (!state.isOffline) {
        unawaited(retryPendingMessages());
      }
    });
  }

  void _updateOfflineState(List<ConnectivityResult> results) {
    final bool offline = results.every(
      (ConnectivityResult result) => result == ConnectivityResult.none,
    );
    if (offline == state.isOffline) {
      return;
    }
    state = state.copyWith(isOffline: offline);
  }

  Future<void> _processUserMessage({
    required AssistantMessage userMessage,
    AiQueryIntent? intentOverride,
    bool enableStreaming = true,
    bool allowDowngrade = true,
  }) async {
    if (!ref.mounted) {
      return;
    }
    final AskFinancialAssistantUseCase useCase = ref.read(
      askFinancialAssistantUseCaseProvider,
    );
    final LoggerService logger = ref.read(loggerServiceProvider);
    final Uuid uuid = ref.read(uuidGeneratorProvider);
    final Locale locale = ref.read(appLocaleProvider);
    final String localeTag = locale.toLanguageTag();
    final AsyncValue<AuthUser?> authState = ref.read(authControllerProvider);
    final String userId =
        authState.asData?.value?.uid ?? _kOfflineUserFallbackId;
    final Set<AssistantFilter> contextFilters =
        userMessage.contextFilters.isEmpty
        ? state.activeFilters
        : userMessage.contextFilters;

    AssistantMessage? streamingMessage;
    if (enableStreaming) {
      streamingMessage = AssistantMessage(
        id: uuid.v4(),
        author: AssistantMessageAuthor.assistant,
        content: '',
        createdAt: DateTime.now(),
        isStreaming: true,
      );
    }

    state = state.copyWith(
      streamingMessage: streamingMessage,
      isSending: true,
      messages: _replaceMessage(
        userMessage.id,
        userMessage.copyWith(
          deliveryStatus: AssistantMessageDeliveryStatus.sending,
        ),
      ),
    );

    try {
      final String contentForQuery = _applyDialogContext(
        currentMessage: userMessage,
      );
      final AiQueryIntent resolvedIntent =
          intentOverride ?? _resolveIntent(contextFilters, userMessage.content);
      final AiUserQueryEntity query = AiUserQueryEntity(
        id: uuid.v4(),
        userId: userId,
        content: contentForQuery,
        contextSignals: _buildContextSignals(contextFilters),
        locale: localeTag,
        intent: resolvedIntent,
        createdAt: DateTime.now(),
      );

      final AiLlmResultEntity result = await useCase.execute(query);

      final AssistantMessage baseAssistantMessage =
          streamingMessage ??
          AssistantMessage(
            id: uuid.v4(),
            author: AssistantMessageAuthor.assistant,
            content: '',
            createdAt: DateTime.now(),
          );
      final AssistantMessage finalAssistantMessage = baseAssistantMessage
          .copyWith(
            isStreaming: false,
            content: result.content,
            createdAt: result.createdAt,
          );

      final List<AssistantMessage> deliveredMessages = _replaceMessage(
        userMessage.id,
        userMessage.copyWith(
          deliveryStatus: AssistantMessageDeliveryStatus.delivered,
        ),
      );

      state = state.copyWith(
        messages: <AssistantMessage>[
          ...deliveredMessages,
          finalAssistantMessage,
        ],
        streamingMessage: null,
        isSending: false,
        lastError: AssistantErrorType.none,
      );
    } on TimeoutException catch (error) {
      logger.logError('AI assistant timeout', error);
      _handleSendFailure(
        userMessage: userMessage,
        errorType: AssistantErrorType.timeout,
      );
    } on AiAssistantDisabledException catch (error) {
      logger.logInfo('AI assistant disabled: ${error.message}');
      _handleSendFailure(
        userMessage: userMessage,
        errorType: AssistantErrorType.disabled,
      );
    } on AiAssistantRateLimitException catch (error) {
      logger.logError('AI assistant rate limit', error);
      _handleSendFailure(
        userMessage: userMessage,
        errorType: AssistantErrorType.rateLimit,
      );
    } on AiAssistantServerException catch (error) {
      logger.logError('AI assistant server error', error);
      if (allowDowngrade && enableStreaming) {
        await _processUserMessage(
          userMessage: userMessage,
          intentOverride: intentOverride,
          enableStreaming: false,
          allowDowngrade: false,
        );
        return;
      }
      _handleSendFailure(
        userMessage: userMessage,
        errorType: AssistantErrorType.server,
      );
    } on AiAssistantConfigurationException catch (error) {
      logger.logError('AI assistant configuration error', error);
      _handleSendFailure(
        userMessage: userMessage,
        errorType: AssistantErrorType.configuration,
      );
    } on AiAssistantException catch (error) {
      logger.logError('AI assistant unexpected error', error);
      _handleSendFailure(
        userMessage: userMessage,
        errorType: AssistantErrorType.unknown,
      );
    } on Object catch (error) {
      logger.logError('AI assistant request failed', error);
      final AssistantErrorType errorType = _isNetworkError(error)
          ? AssistantErrorType.network
          : AssistantErrorType.unknown;
      _handleSendFailure(userMessage: userMessage, errorType: errorType);
    }
  }

  void _handleSendFailure({
    required AssistantMessage userMessage,
    required AssistantErrorType errorType,
  }) {
    final AssistantMessageDeliveryStatus fallbackStatus = state.isOffline
        ? AssistantMessageDeliveryStatus.pending
        : AssistantMessageDeliveryStatus.failed;
    state = state.copyWith(
      messages: _replaceMessage(
        userMessage.id,
        userMessage.copyWith(deliveryStatus: fallbackStatus),
      ),
      streamingMessage: null,
      isSending: false,
      lastError: errorType,
    );
  }

  List<AssistantMessage> _replaceMessage(
    String messageId,
    AssistantMessage replacement,
  ) {
    final List<AssistantMessage> mutable = List<AssistantMessage>.from(
      state.messages,
    );
    final int index = mutable.indexWhere(
      (AssistantMessage message) => message.id == messageId,
    );
    if (index == -1) {
      return mutable;
    }
    mutable[index] = replacement;
    return mutable;
  }

  List<String> _buildContextSignals(Set<AssistantFilter> filters) {
    final List<String> signals = <String>[];
    for (final AssistantFilter filter in filters) {
      switch (filter) {
        case AssistantFilter.currentMonth:
          signals.add('period:current_month');
        case AssistantFilter.last30Days:
          signals.add('period:last_30_days');
        case AssistantFilter.budgetsOnly:
          signals.add('focus:budgets');
      }
    }
    return signals;
  }

  String _applyDialogContext({required AssistantMessage currentMessage}) {
    final List<AssistantMessage> history = _collectDialogHistory(
      currentMessageId: currentMessage.id,
    );
    if (history.isEmpty) {
      return currentMessage.content;
    }

    final StringBuffer buffer = StringBuffer()
      ..writeln(
        'Контекст диалога (последние $_kDialogContextLimit сообщений):',
      );
    for (final AssistantMessage message in history) {
      final String label = message.author == AssistantMessageAuthor.user
          ? 'Пользователь'
          : 'Ассистент';
      buffer.writeln('- $label: ${message.content}');
    }
    buffer.writeln();
    buffer.write('Текущий вопрос: ${currentMessage.content}');
    return buffer.toString();
  }

  List<AssistantMessage> _collectDialogHistory({
    required String currentMessageId,
  }) {
    final List<AssistantMessage> candidates = state.messages
        .where((AssistantMessage message) {
          if (message.id == currentMessageId) {
            return false;
          }
          if (message.author == AssistantMessageAuthor.system) {
            return false;
          }
          if (message.isStreaming || message.content.trim().isEmpty) {
            return false;
          }
          if (message.author == AssistantMessageAuthor.user &&
              message.deliveryStatus !=
                  AssistantMessageDeliveryStatus.delivered) {
            return false;
          }
          return true;
        })
        .toList(growable: false);

    if (candidates.length <= _kDialogContextLimit) {
      return candidates;
    }
    return candidates.sublist(candidates.length - _kDialogContextLimit);
  }

  AiQueryIntent _resolveIntent(Set<AssistantFilter> filters, String prompt) {
    if (filters.contains(AssistantFilter.budgetsOnly)) {
      return AiQueryIntent.budgeting;
    }
    if (filters.contains(AssistantFilter.currentMonth) ||
        filters.contains(AssistantFilter.last30Days)) {
      return AiQueryIntent.analytics;
    }

    final String normalized = prompt.toLowerCase();
    if (normalized.contains('budget') || normalized.contains('бюдж')) {
      return AiQueryIntent.budgeting;
    }
    if (normalized.contains('save') || normalized.contains('накоп')) {
      return AiQueryIntent.savings;
    }
    if (normalized.contains('account') || normalized.contains('счет')) {
      return AiQueryIntent.accounts;
    }
    if (normalized.contains('transaction') || normalized.contains('транзак')) {
      return AiQueryIntent.transactions;
    }
    return AiQueryIntent.insights;
  }

  bool _isNetworkError(Object error) {
    return error is SocketException;
  }

  Future<bool> _isCurrentlyOffline() async {
    if (!ref.mounted) {
      return true;
    }
    final Connectivity connectivity = ref.read(connectivityProvider);
    final List<ConnectivityResult> results = await connectivity
        .checkConnectivity();
    if (!ref.mounted) {
      return true;
    }
    return results.every(
      (ConnectivityResult result) => result == ConnectivityResult.none,
    );
  }
}
