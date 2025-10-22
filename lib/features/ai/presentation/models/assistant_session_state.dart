import 'package:freezed_annotation/freezed_annotation.dart';

import 'assistant_filters.dart';
import 'assistant_message.dart';

part 'assistant_session_state.freezed.dart';

/// Тип последней ошибки в диалоге ассистента.
enum AssistantErrorType {
  none,
  network,
  timeout,
  rateLimit,
  server,
  disabled,
  configuration,
  unknown,
}

/// Иммутабельное состояние сессии ассистента.
@freezed
abstract class AssistantSessionState with _$AssistantSessionState {
  const factory AssistantSessionState({
    @Default(<AssistantMessage>[]) List<AssistantMessage> messages,
    AssistantMessage? streamingMessage,
    @Default(false) bool isSending,
    @Default(false) bool isOffline,
    @Default(<AssistantFilter>{}) Set<AssistantFilter> activeFilters,
    @Default(AssistantErrorType.none) AssistantErrorType lastError,
  }) = _AssistantSessionState;
}
