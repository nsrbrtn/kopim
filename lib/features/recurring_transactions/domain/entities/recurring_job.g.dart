// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringJob _$RecurringJobFromJson(Map<String, dynamic> json) =>
    _RecurringJob(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      payload: json['payload'] as String,
      runAt: DateTime.parse(json['runAt'] as String),
      attempts: (json['attempts'] as num).toInt(),
      lastError: json['lastError'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RecurringJobToJson(_RecurringJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'payload': instance.payload,
      'runAt': instance.runAt.toIso8601String(),
      'attempts': instance.attempts,
      'lastError': instance.lastError,
      'createdAt': instance.createdAt.toIso8601String(),
    };
