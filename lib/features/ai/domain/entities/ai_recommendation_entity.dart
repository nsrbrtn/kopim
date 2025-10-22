import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_recommendation_entity.freezed.dart';
part 'ai_recommendation_entity.g.dart';

/// Тип рекомендации, используемый ИИ-ассистентом.
@JsonEnum(alwaysCreate: true)
enum AiRecommendationType { insight, alert, automation, reminder }

/// Рекомендация ИИ с деталями и списком действий.
@freezed
abstract class AiRecommendationEntity with _$AiRecommendationEntity {
  const AiRecommendationEntity._();

  const factory AiRecommendationEntity({
    required String id,
    required String queryId,
    required String title,
    required String description,
    @Default(AiRecommendationType.insight) AiRecommendationType type,
    @Default(<String>[]) List<String> tags,
    @Default(<AiRecommendationActionEntity>[])
    List<AiRecommendationActionEntity> actions,
    AiRecommendationImpact? impact,
    double? estimatedSavings,
    double? estimatedIncomeIncrease,
    required DateTime createdAt,
    DateTime? validUntil,
  }) = _AiRecommendationEntity;

  factory AiRecommendationEntity.fromJson(Map<String, Object?> json) =>
      _$AiRecommendationEntityFromJson(json);
}

/// Дополнительное действие, которое пользователь может выполнить по рекомендации.
@freezed
abstract class AiRecommendationActionEntity
    with _$AiRecommendationActionEntity {
  const AiRecommendationActionEntity._();

  const factory AiRecommendationActionEntity({
    required String actionId,
    required String label,
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    String? deepLink,
  }) = _AiRecommendationActionEntity;

  factory AiRecommendationActionEntity.fromJson(Map<String, Object?> json) =>
      _$AiRecommendationActionEntityFromJson(json);
}

/// Оценка эффекта рекомендации в числовом и текстовом виде.
@freezed
abstract class AiRecommendationImpact with _$AiRecommendationImpact {
  const AiRecommendationImpact._();

  const factory AiRecommendationImpact({
    double? projectedSavings,
    double? projectedIncome,
    double? riskScore,
    String? narrative,
  }) = _AiRecommendationImpact;

  factory AiRecommendationImpact.fromJson(Map<String, Object?> json) =>
      _$AiRecommendationImpactFromJson(json);
}
