import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'home_account_monthly_summary.freezed.dart';

@freezed
abstract class HomeAccountMonthlySummary with _$HomeAccountMonthlySummary {
  const factory HomeAccountMonthlySummary({
    required MoneyAmount income,
    required MoneyAmount expense,
  }) = _HomeAccountMonthlySummary;

  const HomeAccountMonthlySummary._();

  MoneyAmount get net {
    final int targetScale = income.scale > expense.scale
        ? income.scale
        : expense.scale;
    final MoneyAmount normalizedIncome = rescaleMoneyAmount(
      income,
      targetScale,
    );
    final MoneyAmount normalizedExpense = rescaleMoneyAmount(
      expense,
      targetScale,
    );
    return MoneyAmount(
      minor: normalizedIncome.minor - normalizedExpense.minor,
      scale: targetScale,
    );
  }
}
