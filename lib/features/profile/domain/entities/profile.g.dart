// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  uid: json['uid'] as String,
  name: json['name'] as String? ?? '',
  currency:
      $enumDecodeNullable(_$ProfileCurrencyEnumMap, json['currency']) ??
      ProfileCurrency.rub,
  locale: json['locale'] as String? ?? 'en',
  photoUrl: json['photoUrl'] as String?,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'currency': _$ProfileCurrencyEnumMap[instance.currency]!,
  'locale': instance.locale,
  'photoUrl': instance.photoUrl,
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$ProfileCurrencyEnumMap = {
  ProfileCurrency.rub: 'rub',
  ProfileCurrency.usd: 'usd',
  ProfileCurrency.eur: 'eur',
  ProfileCurrency.uah: 'uah',
  ProfileCurrency.kzt: 'kzt',
  ProfileCurrency.gel: 'gel',
};
