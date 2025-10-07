import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_dashboard_preferences.freezed.dart';
part 'home_dashboard_preferences.g.dart';

@freezed
abstract class HomeDashboardPreferences with _$HomeDashboardPreferences {
  const factory HomeDashboardPreferences({
    @Default(false) bool showGamificationWidget,
    @Default(false) bool showBudgetWidget,
    String? budgetId,
  }) = _HomeDashboardPreferences;

  factory HomeDashboardPreferences.fromJson(Map<String, dynamic> json) =>
      _$HomeDashboardPreferencesFromJson(json);
}
