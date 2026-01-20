import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

import 'budget.dart';
import 'budget_instance.dart';

part 'budget_progress.freezed.dart';

@freezed
abstract class BudgetProgress with _$BudgetProgress {
  const factory BudgetProgress({
    required Budget budget,
    required BudgetInstance instance,
    required MoneyAmount spent,
    required MoneyAmount remaining,
    required double utilization,
    required bool isExceeded,
  }) = _BudgetProgress;
}
