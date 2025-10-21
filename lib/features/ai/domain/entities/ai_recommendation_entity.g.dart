// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_recommendation_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiRecommendationEntity _$AiRecommendationEntityFromJson(
  Map<String, dynamic> json,
) => _AiRecommendationEntity(
  id: json['id'] as String,
  queryId: json['queryId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type:
      $enumDecodeNullable(_$AiRecommendationTypeEnumMap, json['type']) ??
      AiRecommendationType.insight,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  actions:
      (json['actions'] as List<dynamic>?)
          ?.map(
            (e) => AiRecommendationActionEntity.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <AiRecommendationActionEntity>[],
  impact: json['impact'] == null
      ? null
      : AiRecommendationImpact.fromJson(json['impact'] as Map<String, dynamic>),
  estimatedSavings: (json['estimatedSavings'] as num?)?.toDouble(),
  estimatedIncomeIncrease: (json['estimatedIncomeIncrease'] as num?)
      ?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
);

Map<String, dynamic> _$AiRecommendationEntityToJson(
  _AiRecommendationEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'queryId': instance.queryId,
  'title': instance.title,
  'description': instance.description,
  'type': _$AiRecommendationTypeEnumMap[instance.type]!,
  'tags': instance.tags,
  'actions': instance.actions,
  'impact': instance.impact,
  'estimatedSavings': instance.estimatedSavings,
  'estimatedIncomeIncrease': instance.estimatedIncomeIncrease,
  'createdAt': instance.createdAt.toIso8601String(),
  'validUntil': instance.validUntil?.toIso8601String(),
};

const _$AiRecommendationTypeEnumMap = {
  AiRecommendationType.insight: 'insight',
  AiRecommendationType.alert: 'alert',
  AiRecommendationType.automation: 'automation',
  AiRecommendationType.reminder: 'reminder',
};

_AiRecommendationActionEntity _$AiRecommendationActionEntityFromJson(
  Map<String, dynamic> json,
) => _AiRecommendationActionEntity(
  actionId: json['actionId'] as String,
  label: json['label'] as String,
  payload:
      json['payload'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  deepLink: json['deepLink'] as String?,
);

Map<String, dynamic> _$AiRecommendationActionEntityToJson(
  _AiRecommendationActionEntity instance,
) => <String, dynamic>{
  'actionId': instance.actionId,
  'label': instance.label,
  'payload': instance.payload,
  'deepLink': instance.deepLink,
};

_AiRecommendationImpact _$AiRecommendationImpactFromJson(
  Map<String, dynamic> json,
) => _AiRecommendationImpact(
  projectedSavings: (json['projectedSavings'] as num?)?.toDouble(),
  projectedIncome: (json['projectedIncome'] as num?)?.toDouble(),
  riskScore: (json['riskScore'] as num?)?.toDouble(),
  narrative: json['narrative'] as String?,
);

Map<String, dynamic> _$AiRecommendationImpactToJson(
  _AiRecommendationImpact instance,
) => <String, dynamic>{
  'projectedSavings': instance.projectedSavings,
  'projectedIncome': instance.projectedIncome,
  'riskScore': instance.riskScore,
  'narrative': instance.narrative,
};
