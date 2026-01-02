import 'package:flutter/foundation.dart';

@immutable
class AnalyticsFilter {
  const AnalyticsFilter({
    required this.start,
    required this.end,
    this.accountId,
    this.accountIds,
    this.categoryId,
    this.includeSubcategories = true,
  });

  factory AnalyticsFilter.monthly({DateTime? reference}) {
    final DateTime now = reference ?? DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month);
    final DateTime monthEnd = DateTime(now.year, now.month + 1);
    return AnalyticsFilter(start: monthStart, end: monthEnd);
  }

  factory AnalyticsFilter.fromJson(Map<String, Object?> json) {
    return AnalyticsFilter(
      start: DateTime.parse(json['start']! as String),
      end: DateTime.parse(json['end']! as String),
      accountId: json['accountId'] as String?,
      accountIds: (json['accountIds'] as List<dynamic>?)
          ?.map((dynamic e) => e as String)
          .toList(),
      categoryId: json['categoryId'] as String?,
      includeSubcategories: json['includeSubcategories'] as bool? ?? true,
    );
  }

  final DateTime start;
  final DateTime end;
  final String? accountId;
  final List<String>? accountIds;
  final String? categoryId;
  final bool includeSubcategories;

  Map<String, Object?> toJson() => <String, Object?>{
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'accountId': accountId,
    'accountIds': accountIds,
    'categoryId': categoryId,
    'includeSubcategories': includeSubcategories,
  };

  AnalyticsFilter copyWith({
    DateTime? start,
    DateTime? end,
    String? accountId,
    List<String>? accountIds,
    String? categoryId,
    bool? includeSubcategories,
  }) {
    return AnalyticsFilter(
      start: start ?? this.start,
      end: end ?? this.end,
      accountId: accountId ?? this.accountId,
      accountIds: accountIds ?? this.accountIds,
      categoryId: categoryId ?? this.categoryId,
      includeSubcategories: includeSubcategories ?? this.includeSubcategories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsFilter &&
        other.start == start &&
        other.end == end &&
        other.accountId == accountId &&
        listEquals(other.accountIds, accountIds) &&
        other.categoryId == categoryId &&
        other.includeSubcategories == includeSubcategories;
  }

  @override
  int get hashCode => Object.hash(
    start,
    end,
    accountId,
    accountIds == null ? null : Object.hashAll(accountIds!),
    categoryId,
    includeSubcategories,
  );
}

extension AnalyticsFilterX on AnalyticsFilter {
  bool includesDate(DateTime date) {
    return !date.isBefore(start) && date.isBefore(end);
  }

  bool includesAccount(String accountId) {
    final List<String>? ids = accountIds;
    if (ids != null && ids.isNotEmpty) {
      return ids.contains(accountId);
    }
    if (this.accountId != null) {
      return this.accountId == accountId;
    }
    return true;
  }
}
