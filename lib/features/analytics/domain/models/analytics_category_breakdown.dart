import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_category_breakdown.freezed.dart';

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
