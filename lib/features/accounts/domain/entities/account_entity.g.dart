// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountEntity _$AccountEntityFromJson(Map<String, dynamic> json) =>
    _AccountEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      color: json['color'] as String?,
      gradientId: json['gradientId'] as String?,
      iconName: json['iconName'] as String?,
      iconStyle: json['iconStyle'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isPrimary: json['isPrimary'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
    );

Map<String, dynamic> _$AccountEntityToJson(_AccountEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance,
      'openingBalance': instance.openingBalance,
      'currency': instance.currency,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'color': instance.color,
      'gradientId': instance.gradientId,
      'iconName': instance.iconName,
      'iconStyle': instance.iconStyle,
      'isDeleted': instance.isDeleted,
      'isPrimary': instance.isPrimary,
      'isHidden': instance.isHidden,
    };
