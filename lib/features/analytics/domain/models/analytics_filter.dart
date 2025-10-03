import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_filter.freezed.dart';
part 'analytics_filter.g.dart';

@freezed
abstract class AnalyticsFilter with _$AnalyticsFilter {
  const AnalyticsFilter._();

  const factory AnalyticsFilter({
    required DateTime start,
    required DateTime end,
    String? accountId,
    String? categoryId,
  }) = _AnalyticsFilter;

  factory AnalyticsFilter.fromJson(Map<String, Object?> json) =>
      _$AnalyticsFilterFromJson(json);

  factory AnalyticsFilter.monthly({DateTime? reference}) {
    final DateTime now = reference ?? DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month);
    final DateTime monthEnd = DateTime(now.year, now.month + 1);
    return AnalyticsFilter(start: monthStart, end: monthEnd);
  }
}

extension AnalyticsFilterX on AnalyticsFilter {
  bool includesDate(DateTime date) {
    return !date.isBefore(start) && date.isBefore(end);
  }
}
