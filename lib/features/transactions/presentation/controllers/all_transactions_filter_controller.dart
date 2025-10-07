import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_transactions_filter_controller.freezed.dart';
part 'all_transactions_filter_controller.g.dart';

@freezed
abstract class AllTransactionsFilterState with _$AllTransactionsFilterState {
  const factory AllTransactionsFilterState({
    DateTimeRange? dateRange,
    String? accountId,
    String? categoryId,
  }) = _AllTransactionsFilterState;
}

extension AllTransactionsFilterStateX on AllTransactionsFilterState {
  bool get hasFilters =>
      dateRange != null || accountId != null || categoryId != null;
}

@riverpod
class AllTransactionsFilterController
    extends _$AllTransactionsFilterController {
  @override
  AllTransactionsFilterState build() => const AllTransactionsFilterState();

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  void setAccount(String? accountId) {
    state = state.copyWith(accountId: accountId);
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void clear() {
    state = const AllTransactionsFilterState();
  }
}
