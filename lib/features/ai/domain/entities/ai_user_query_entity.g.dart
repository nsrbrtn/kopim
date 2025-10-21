// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_user_query_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiUserQueryEntity _$AiUserQueryEntityFromJson(Map<String, dynamic> json) =>
    _AiUserQueryEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      contextSignals:
          (json['contextSignals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      locale: json['locale'] as String?,
      intent:
          $enumDecodeNullable(_$AiQueryIntentEnumMap, json['intent']) ??
          AiQueryIntent.unknown,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AiUserQueryEntityToJson(_AiUserQueryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'content': instance.content,
      'contextSignals': instance.contextSignals,
      'locale': instance.locale,
      'intent': _$AiQueryIntentEnumMap[instance.intent]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AiQueryIntentEnumMap = {
  AiQueryIntent.analytics: 'analytics',
  AiQueryIntent.budgeting: 'budgeting',
  AiQueryIntent.accounts: 'accounts',
  AiQueryIntent.transactions: 'transactions',
  AiQueryIntent.savings: 'savings',
  AiQueryIntent.insights: 'insights',
  AiQueryIntent.unknown: 'unknown',
};
