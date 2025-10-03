import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_filter_controller.freezed.dart';
part 'analytics_filter_controller.g.dart';

@freezed
abstract class AnalyticsFilterState with _$AnalyticsFilterState {
  const AnalyticsFilterState._();

  const factory AnalyticsFilterState({
    required DateTimeRange dateRange,
    String? accountId,
    String? categoryId,
  }) = _AnalyticsFilterState;

  factory AnalyticsFilterState.initial() {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month);
    final DateTime endInclusive = DateTime(
      now.year,
      now.month + 1,
    ).subtract(const Duration(days: 1));
    return AnalyticsFilterState(
      dateRange: DateTimeRange(start: start, end: endInclusive),
    );
  }
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
      accountId: accountId,
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
    state = state.copyWith(dateRange: normalized);
  }

  void updateAccount(String? accountId) {
    if (state.accountId == accountId) {
      return;
    }
    state = state.copyWith(accountId: accountId);
  }

  void updateCategory(String? categoryId) {
    if (state.categoryId == categoryId) {
      return;
    }
    state = state.copyWith(categoryId: categoryId);
  }
}
