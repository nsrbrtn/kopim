import 'package:freezed_annotation/freezed_annotation.dart';

import 'budget_category_allocation.dart';
import 'budget_period.dart';
import 'budget_scope.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
abstract class Budget with _$Budget {
  const Budget._();

  const factory Budget({
    required String id,
    required String title,
    @JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson)
    required BudgetPeriod period,
    required DateTime startDate,
    DateTime? endDate,
    required double amount,
    @JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson)
    required BudgetScope scope,
    @Default(<String>[]) List<String> categories,
    @Default(<String>[]) List<String> accounts,
    @Default(<BudgetCategoryAllocation>[])
    List<BudgetCategoryAllocation> categoryAllocations,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _Budget;

  factory Budget.fromJson(Map<String, Object?> json) => _$BudgetFromJson(json);
}

String _periodToJson(BudgetPeriod period) => period.storageValue;

String _scopeToJson(BudgetScope scope) => scope.storageValue;
