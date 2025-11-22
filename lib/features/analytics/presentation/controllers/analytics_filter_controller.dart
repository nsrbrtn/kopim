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
    this.period = AnalyticsPeriodPreset.thisMonth,
    this.monthAnchor,
  });

  static const Object _unset = Object();

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

  final DateTimeRange dateRange;
  final Set<String> accountIds;
  final String? categoryId;
  final AnalyticsPeriodPreset period;
  final DateTime? monthAnchor;

  AnalyticsFilterState copyWith({
    DateTimeRange? dateRange,
    Object? accountIds = _unset,
    Object? categoryId = _unset,
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
        other.period == period &&
        other.monthAnchor == monthAnchor;
  }

  @override
  int get hashCode => Object.hash(
    dateRange,
    Object.hashAll(accountIds),
    categoryId,
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
    );
  }
}

@riverpod
class AnalyticsFilterController extends _$AnalyticsFilterController {
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

  void clearCategory() {
    if (state.categoryId == null) {
      return;
    }
    state = state.copyWith(categoryId: null);
  }
}
