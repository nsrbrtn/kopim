// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_occurrence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringOccurrence _$RecurringOccurrenceFromJson(Map<String, dynamic> json) =>
    _RecurringOccurrence(
      id: json['id'] as String,
      ruleId: json['ruleId'] as String,
      dueAt: DateTime.parse(json['dueAt'] as String),
      status:
          $enumDecodeNullable(
            _$RecurringOccurrenceStatusEnumMap,
            json['status'],
          ) ??
          RecurringOccurrenceStatus.scheduled,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      postedTxId: json['postedTxId'] as String?,
    );

Map<String, dynamic> _$RecurringOccurrenceToJson(
  _RecurringOccurrence instance,
) => <String, dynamic>{
  'id': instance.id,
  'ruleId': instance.ruleId,
  'dueAt': instance.dueAt.toIso8601String(),
  'status': _$RecurringOccurrenceStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'postedTxId': instance.postedTxId,
};

const _$RecurringOccurrenceStatusEnumMap = {
  RecurringOccurrenceStatus.scheduled: 'scheduled',
  RecurringOccurrenceStatus.posted: 'posted',
  RecurringOccurrenceStatus.skipped: 'skipped',
  RecurringOccurrenceStatus.failed: 'failed',
};
