import 'package:freezed_annotation/freezed_annotation.dart';

import 'assistant_filters.dart';

part 'assistant_message.freezed.dart';

/// Участник диалога в интерфейсе ассистента.
enum AssistantMessageAuthor { user, assistant, system }

/// Статус доставки пользовательского сообщения.
enum AssistantMessageDeliveryStatus { delivered, sending, pending, failed }

@freezed
abstract class AssistantMessage with _$AssistantMessage {
  const factory AssistantMessage({
    required String id,
    required AssistantMessageAuthor author,
    required String content,
    required DateTime createdAt,
    @Default(false) bool isStreaming,
    @Default(AssistantMessageDeliveryStatus.delivered)
    AssistantMessageDeliveryStatus deliveryStatus,
    @Default(<AssistantFilter>{}) Set<AssistantFilter> contextFilters,
  }) = _AssistantMessage;
}
