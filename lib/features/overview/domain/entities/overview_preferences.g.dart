// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overview_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OverviewPreferences _$OverviewPreferencesFromJson(Map<String, dynamic> json) =>
    _OverviewPreferences(
      accountIds: (json['accountIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      categoryIds: (json['categoryIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OverviewPreferencesToJson(
  _OverviewPreferences instance,
) => <String, dynamic>{
  'accountIds': instance.accountIds,
  'categoryIds': instance.categoryIds,
};
