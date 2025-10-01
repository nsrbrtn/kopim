import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_category_breakdown.freezed.dart';

@freezed
abstract class AnalyticsCategoryBreakdown with _$AnalyticsCategoryBreakdown {
  const AnalyticsCategoryBreakdown._();

  const factory AnalyticsCategoryBreakdown({
    String? categoryId,
    required double amount,
  }) = _AnalyticsCategoryBreakdown;
}
