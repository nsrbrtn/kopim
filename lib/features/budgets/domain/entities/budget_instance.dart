import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

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
    @JsonKey(includeFromJson: false, includeToJson: false)
    BigInt? amountMinor,
    @JsonKey(includeFromJson: false, includeToJson: false)
    BigInt? spentMinor,
    @JsonKey(includeFromJson: false, includeToJson: false)
    int? amountScale,
    @JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson)
    required BudgetInstanceStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BudgetInstance;

  factory BudgetInstance.fromJson(Map<String, Object?> json) =>
      _$BudgetInstanceFromJson(json);

  MoneyAmount get amountValue => MoneyAmount(
    minor: amountMinor ?? BigInt.zero,
    scale: amountScale ?? 2,
  );

  MoneyAmount get spentValue => MoneyAmount(
    minor: spentMinor ?? BigInt.zero,
    scale: amountScale ?? 2,
  );
}

String _statusToJson(BudgetInstanceStatus status) => status.storageValue;
