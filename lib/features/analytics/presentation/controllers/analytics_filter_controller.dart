import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_filter_controller.g.dart';

enum AnalyticsPeriodPreset { thisMonth, last30Days, customMonth, customRange }

@immutable
class AnalyticsFilterState {
  const AnalyticsFilterState({
    required this.dateRange,
    this.accountIds = const <String>{},
    this.categoryId,
    this.includeSubcategories = true,
    this.period = AnalyticsPeriodPreset.thisMonth,
    this.monthAnchor,
  });

  factory AnalyticsFilterState.initial() {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month);
    final DateTime endInclusive = DateTime(
      now.year,
      now.month + 1,
    ).subtract(const Duration(days: 1));
    return AnalyticsFilterState(
      dateRange: DateTimeRange(start: start, end: endInclusive),
      monthAnchor: start,
    );
  }

  static const Object _unset = Object();

  final DateTimeRange dateRange;
  final Set<String> accountIds;
  final String? categoryId;
  final bool includeSubcategories;
  final AnalyticsPeriodPreset period;
  final DateTime? monthAnchor;

  AnalyticsFilterState copyWith({
    DateTimeRange? dateRange,
    Object? accountIds = _unset,
    Object? categoryId = _unset,
    Object? includeSubcategories = _unset,
    AnalyticsPeriodPreset? period,
    DateTime? monthAnchor,
  }) {
    return AnalyticsFilterState(
      dateRange: dateRange ?? this.dateRange,
      accountIds: accountIds == _unset
          ? this.accountIds
          : accountIds as Set<String>,
      categoryId: categoryId == _unset
          ? this.categoryId
          : categoryId as String?,
      includeSubcategories: includeSubcategories == _unset
          ? this.includeSubcategories
          : includeSubcategories as bool,
      period: period ?? this.period,
      monthAnchor: monthAnchor ?? this.monthAnchor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsFilterState &&
        other.dateRange == dateRange &&
        setEquals(other.accountIds, accountIds) &&
        other.categoryId == categoryId &&
        other.includeSubcategories == includeSubcategories &&
        other.period == period &&
        other.monthAnchor == monthAnchor;
  }

  @override
  int get hashCode => Object.hash(
    dateRange,
    Object.hashAll(accountIds),
    categoryId,
    includeSubcategories,
    period,
    monthAnchor,
  );
}

extension AnalyticsFilterStateX on AnalyticsFilterState {
  AnalyticsFilter toDomain() {
    final DateTime normalizedStart = DateUtils.dateOnly(dateRange.start);
    final DateTime normalizedEndInclusive = DateUtils.dateOnly(dateRange.end);
    final DateTime endExclusive = normalizedEndInclusive.add(
      const Duration(days: 1),
    );

    return AnalyticsFilter(
      start: normalizedStart,
      end: endExclusive,
      accountId: accountIds.length == 1 ? accountIds.first : null,
      accountIds: accountIds.isEmpty ? null : accountIds.toList(),
      categoryId: categoryId,
      includeSubcategories: includeSubcategories,
    );
  }
}

@riverpod
class AnalyticsFilterController extends _$AnalyticsFilterController {
  static final DateTime _kMinSupportedDate = DateTime(2000);

  @override
  AnalyticsFilterState build() {
    return AnalyticsFilterState.initial();
  }

  void updateDateRange(DateTimeRange range) {
    final DateTimeRange normalized = DateTimeRange(
      start: DateUtils.dateOnly(range.start),
      end: DateUtils.dateOnly(range.end),
    );
    if (normalized == state.dateRange) {
      return;
    }
    state = state.copyWith(
      dateRange: normalized,
      period: AnalyticsPeriodPreset.customRange,
      monthAnchor: null,
    );
  }

  void applyThisMonth({DateTime? reference}) {
    final DateTime now = reference ?? DateTime.now();
    final DateTime start = DateTime(now.year, now.month);
    final DateTime end = DateTime(
      now.year,
      now.month + 1,
    ).subtract(const Duration(days: 1));
    state = state.copyWith(
      dateRange: DateTimeRange(start: start, end: end),
      monthAnchor: start,
      period: AnalyticsPeriodPreset.thisMonth,
    );
  }

  void applyLast30Days({DateTime? until}) {
    final DateTime now = DateUtils.dateOnly(until ?? DateTime.now());
    final DateTime start = DateUtils.dateOnly(
      now.subtract(const Duration(days: 29)),
    );
    state = state.copyWith(
      dateRange: DateTimeRange(start: start, end: now),
      period: AnalyticsPeriodPreset.last30Days,
      monthAnchor: null,
    );
  }

  void selectMonth(DateTime month) {
    final DateTime start = DateTime(month.year, month.month);
    final DateTime end = DateTime(
      month.year,
      month.month + 1,
    ).subtract(const Duration(days: 1));
    state = state.copyWith(
      dateRange: DateTimeRange(start: start, end: end),
      monthAnchor: start,
      period: AnalyticsPeriodPreset.customMonth,
    );
  }

  void goToPreviousMonth() {
    final DateTime active = _resolveActiveMonth();
    final DateTime previous = DateTime(active.year, active.month - 1);
    if (!previous.isBefore(_kMinSupportedDate)) {
      selectMonth(previous);
    }
  }

  void goToNextMonth() {
    final DateTime active = _resolveActiveMonth();
    final DateTime currentMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );
    final DateTime next = DateTime(active.year, active.month + 1);
    if (next.isAfter(currentMonth)) {
      return;
    }
    selectMonth(next);
  }

  void goToPreviousRangeStep() {
    final DateTime start = state.dateRange.start;
    final DateTime end = state.dateRange.end;
    if (start.isBefore(_kMinSupportedDate) ||
        start.isAtSameMomentAs(_kMinSupportedDate)) {
      return;
    }
    if (_isMonthBased()) {
      goToPreviousMonth();
      return;
    }
    final int spanDays = end.difference(start).inDays + 1;
    DateTime newStart = start.subtract(Duration(days: spanDays));
    DateTime newEnd = end.subtract(Duration(days: spanDays));
    if (newStart.isBefore(_kMinSupportedDate)) {
      newStart = _kMinSupportedDate;
      newEnd = newStart.add(Duration(days: spanDays - 1));
    }
    state = state.copyWith(
      dateRange: DateTimeRange(start: newStart, end: newEnd),
      monthAnchor: null,
    );
  }

  void goToNextRangeStep() {
    final DateTime start = state.dateRange.start;
    final DateTime end = state.dateRange.end;
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    if (_isMonthBased()) {
      goToNextMonth();
      return;
    }
    if (!end.isBefore(today)) {
      return;
    }
    final int spanDays = end.difference(start).inDays + 1;
    DateTime newStart = start.add(Duration(days: spanDays));
    DateTime newEnd = end.add(Duration(days: spanDays));
    if (newEnd.isAfter(today)) {
      newEnd = today;
      newStart = newEnd.subtract(Duration(days: spanDays - 1));
    }
    state = state.copyWith(
      dateRange: DateTimeRange(start: newStart, end: newEnd),
      monthAnchor: null,
    );
  }

  DateTime _resolveActiveMonth() {
    final DateTime anchor = state.monthAnchor ?? state.dateRange.start;
    return DateTime(anchor.year, anchor.month);
  }

  bool _isMonthBased() {
    return state.period == AnalyticsPeriodPreset.thisMonth ||
        state.period == AnalyticsPeriodPreset.customMonth;
  }

  void toggleAccount(String accountId) {
    final Set<String> next = <String>{...state.accountIds};
    if (next.contains(accountId)) {
      next.remove(accountId);
    } else {
      next.add(accountId);
    }
    state = state.copyWith(accountIds: next);
  }

  void setAccounts(Set<String> accountIds) {
    if (setEquals(accountIds, state.accountIds)) {
      return;
    }
    state = state.copyWith(accountIds: accountIds);
  }

  void clearAccounts() {
    if (state.accountIds.isEmpty) {
      return;
    }
    state = state.copyWith(accountIds: <String>{});
  }

  void updateCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void updateIncludeSubcategories(bool include) {
    if (state.includeSubcategories == include) {
      return;
    }
    state = state.copyWith(includeSubcategories: include);
  }

  void clearCategory() {
    if (state.categoryId == null) {
      return;
    }
    state = state.copyWith(categoryId: null);
  }
}
