import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_user_query_entity.freezed.dart';
part 'ai_user_query_entity.g.dart';

/// Категория намерений запроса пользователя, которую определяет
/// финансовый ассистент для маршрутизации обработки.
@JsonEnum(alwaysCreate: true)
enum AiQueryIntent {
  analytics,
  budgeting,
  accounts,
  transactions,
  savings,
  insights,
  unknown,
}

/// Иммутабельная модель запроса пользователя к ИИ-ассистенту.
@freezed
class AiUserQueryEntity with _$AiUserQueryEntity {
  const AiUserQueryEntity._();

  const factory AiUserQueryEntity({
    required String id,
    required String userId,
    required String content,
    @Default(<String>[]) List<String> contextSignals,
    String? locale,
    @Default(AiQueryIntent.unknown) AiQueryIntent intent,
    required DateTime createdAt,
  }) = _AiUserQueryEntity;

  factory AiUserQueryEntity.fromJson(Map<String, Object?> json) =>
      _$AiUserQueryEntityFromJson(json);
}
