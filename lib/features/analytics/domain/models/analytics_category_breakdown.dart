import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_category_breakdown.freezed.dart';

const String analyticsDirectCategoryKeyPrefix = '_direct:';

bool isAnalyticsDirectCategoryKey(String key) {
  return key.startsWith(analyticsDirectCategoryKeyPrefix);
}

String? parseAnalyticsDirectCategoryParentId(String key) {
  if (!isAnalyticsDirectCategoryKey(key)) {
    return null;
  }
  return key.substring(analyticsDirectCategoryKeyPrefix.length);
}

@freezed
abstract class AnalyticsCategoryBreakdown with _$AnalyticsCategoryBreakdown {
  const AnalyticsCategoryBreakdown._();

  const factory AnalyticsCategoryBreakdown({
    String? categoryId,
    required double amount,
    @Default(<AnalyticsCategoryBreakdown>[])
    List<AnalyticsCategoryBreakdown> children,
  }) = _AnalyticsCategoryBreakdown;
}
