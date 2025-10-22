import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_llm_result_entity.freezed.dart';
part 'ai_llm_result_entity.g.dart';

/// Ответ модели с дополнительной аналитикой использования токенов.
@freezed
abstract class AiLlmResultEntity with _$AiLlmResultEntity {
  const AiLlmResultEntity._();

  const factory AiLlmResultEntity({
    required String id,
    required String queryId,
    required String content,
    @Default(<String>[]) List<String> citedSources,
    @Default(0.0) double confidence,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
    required DateTime createdAt,
    String? model,
    int? promptTokens,
    int? completionTokens,
    int? totalTokens,
  }) = _AiLlmResultEntity;

  factory AiLlmResultEntity.fromJson(Map<String, Object?> json) =>
      _$AiLlmResultEntityFromJson(json);
}
