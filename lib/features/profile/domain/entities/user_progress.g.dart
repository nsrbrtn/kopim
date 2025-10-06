// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProgress _$UserProgressFromJson(Map<String, dynamic> json) =>
    _UserProgress(
      totalTx: (json['totalTx'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      title: json['title'] as String,
      nextThreshold: (json['nextThreshold'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserProgressToJson(_UserProgress instance) =>
    <String, dynamic>{
      'totalTx': instance.totalTx,
      'level': instance.level,
      'title': instance.title,
      'nextThreshold': instance.nextThreshold,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
