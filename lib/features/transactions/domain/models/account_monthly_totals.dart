import 'package:kopim/core/money/money_utils.dart';

class AccountMonthlyTotals {
  const AccountMonthlyTotals({
    required this.accountId,
    required this.income,
    required this.expense,
  });

  final String accountId;
  final MoneyAmount income;
  final MoneyAmount expense;
}
