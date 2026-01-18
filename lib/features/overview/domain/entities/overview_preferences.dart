import 'package:freezed_annotation/freezed_annotation.dart';

part 'overview_preferences.freezed.dart';
part 'overview_preferences.g.dart';

@freezed
abstract class OverviewPreferences with _$OverviewPreferences {
  const OverviewPreferences._();

  const factory OverviewPreferences({
    List<String>? accountIds,
    List<String>? categoryIds,
  }) = _OverviewPreferences;

  factory OverviewPreferences.fromJson(Map<String, dynamic> json) =>
      _$OverviewPreferencesFromJson(json);

  Set<String>? get accountIdSet => accountIds?.toSet();
  Set<String>? get categoryIdSet => categoryIds?.toSet();
}
