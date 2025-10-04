import 'package:freezed_annotation/freezed_annotation.dart';

import 'budget_instance_status.dart';

part 'budget_instance.freezed.dart';
part 'budget_instance.g.dart';

@freezed
abstract class BudgetInstance with _$BudgetInstance {
  const BudgetInstance._();

  const factory BudgetInstance({
    required String id,
    required String budgetId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double amount,
    @Default(0.0) double spent,
    @JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson)
    required BudgetInstanceStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BudgetInstance;

  factory BudgetInstance.fromJson(Map<String, Object?> json) =>
      _$BudgetInstanceFromJson(json);
}

String _statusToJson(BudgetInstanceStatus status) => status.storageValue;
