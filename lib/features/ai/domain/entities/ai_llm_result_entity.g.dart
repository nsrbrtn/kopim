// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_llm_result_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiLlmResultEntity _$AiLlmResultEntityFromJson(Map<String, dynamic> json) =>
    _AiLlmResultEntity(
      id: json['id'] as String,
      queryId: json['queryId'] as String,
      content: json['content'] as String,
      citedSources:
          (json['citedSources'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      createdAt: DateTime.parse(json['createdAt'] as String),
      model: json['model'] as String?,
      promptTokens: (json['promptTokens'] as num?)?.toInt(),
      completionTokens: (json['completionTokens'] as num?)?.toInt(),
      totalTokens: (json['totalTokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AiLlmResultEntityToJson(_AiLlmResultEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'queryId': instance.queryId,
      'content': instance.content,
      'citedSources': instance.citedSources,
      'confidence': instance.confidence,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'model': instance.model,
      'promptTokens': instance.promptTokens,
      'completionTokens': instance.completionTokens,
      'totalTokens': instance.totalTokens,
    };
