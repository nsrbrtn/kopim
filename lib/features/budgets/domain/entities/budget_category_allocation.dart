import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_category_allocation.freezed.dart';
part 'budget_category_allocation.g.dart';

@freezed
abstract class BudgetCategoryAllocation with _$BudgetCategoryAllocation {
  const factory BudgetCategoryAllocation({
    required String categoryId,
    required double limit,
  }) = _BudgetCategoryAllocation;

  factory BudgetCategoryAllocation.fromJson(Map<String, dynamic> json) =>
      _$BudgetCategoryAllocationFromJson(json);
}
