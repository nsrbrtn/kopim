// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsFilter _$AnalyticsFilterFromJson(Map<String, dynamic> json) =>
    _AnalyticsFilter(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      accountId: json['accountId'] as String?,
      categoryId: json['categoryId'] as String?,
    );

Map<String, dynamic> _$AnalyticsFilterToJson(_AnalyticsFilter instance) =>
    <String, dynamic>{
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'accountId': instance.accountId,
      'categoryId': instance.categoryId,
    };
