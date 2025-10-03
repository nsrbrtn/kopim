// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringRule _$RecurringRuleFromJson(Map<String, dynamic> json) =>
    _RecurringRule(
      id: json['id'] as String,
      title: json['title'] as String,
      accountId: json['accountId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: json['endAt'] == null
          ? null
          : DateTime.parse(json['endAt'] as String),
      timezone: json['timezone'] as String,
      rrule: json['rrule'] as String,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      autoPost: json['autoPost'] as bool? ?? false,
      reminderMinutesBefore: (json['reminderMinutesBefore'] as num?)?.toInt(),
      shortMonthPolicy:
          $enumDecodeNullable(
            _$RecurringRuleShortMonthPolicyEnumMap,
            json['shortMonthPolicy'],
          ) ??
          RecurringRuleShortMonthPolicy.clipToLastDay,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RecurringRuleToJson(_RecurringRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'accountId': instance.accountId,
      'amount': instance.amount,
      'currency': instance.currency,
      'startAt': instance.startAt.toIso8601String(),
      'endAt': instance.endAt?.toIso8601String(),
      'timezone': instance.timezone,
      'rrule': instance.rrule,
      'notes': instance.notes,
      'isActive': instance.isActive,
      'autoPost': instance.autoPost,
      'reminderMinutesBefore': instance.reminderMinutesBefore,
      'shortMonthPolicy':
          _$RecurringRuleShortMonthPolicyEnumMap[instance.shortMonthPolicy]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RecurringRuleShortMonthPolicyEnumMap = {
  RecurringRuleShortMonthPolicy.clipToLastDay: 'clipToLastDay',
  RecurringRuleShortMonthPolicy.skipMonth: 'skipMonth',
};
