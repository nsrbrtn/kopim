import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'monthly_balance_data.freezed.dart';

@freezed
abstract class MonthlyBalanceData with _$MonthlyBalanceData {
  const MonthlyBalanceData._();

  const factory MonthlyBalanceData({
    required DateTime month,
    required MoneyAmount totalBalance,
  }) = _MonthlyBalanceData;
}
