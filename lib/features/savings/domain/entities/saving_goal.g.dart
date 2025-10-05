// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingGoal _$SavingGoalFromJson(Map<String, dynamic> json) => _SavingGoal(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  targetAmount: (json['targetAmount'] as num).toInt(),
  currentAmount: (json['currentAmount'] as num).toInt(),
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  archivedAt: json['archivedAt'] == null
      ? null
      : DateTime.parse(json['archivedAt'] as String),
);

Map<String, dynamic> _$SavingGoalToJson(_SavingGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'archivedAt': instance.archivedAt?.toIso8601String(),
    };
