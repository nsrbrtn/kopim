// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dashboard_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeDashboardPreferences _$HomeDashboardPreferencesFromJson(
  Map<String, dynamic> json,
) => _HomeDashboardPreferences(
  showGamificationWidget: json['showGamificationWidget'] as bool? ?? false,
  showBudgetWidget: json['showBudgetWidget'] as bool? ?? false,
  budgetId: json['budgetId'] as String?,
);

Map<String, dynamic> _$HomeDashboardPreferencesToJson(
  _HomeDashboardPreferences instance,
) => <String, dynamic>{
  'showGamificationWidget': instance.showGamificationWidget,
  'showBudgetWidget': instance.showBudgetWidget,
  'budgetId': instance.budgetId,
};
