import 'package:kopim/core/money/money_utils.dart';

class MonthlyBalanceTotals {
  const MonthlyBalanceTotals({required this.month, required this.maxBalance});

  final DateTime month;
  final MoneyAmount maxBalance;
}
